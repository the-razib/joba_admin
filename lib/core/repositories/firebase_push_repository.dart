import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/push_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/functions_service.dart';
import 'package:joba_admin/core/services/storage_service.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';

/// Firestore-backed campaign storage plus real FCM dispatch.
///
/// Division of ownership, which the whole feature depends on:
///  - The PANEL owns campaign content (title, body, audience, channel, image).
///  - The CLOUD FUNCTION owns delivery state (`status`, `sentAt`, `sentCount`,
///    `failedCount`, `messageId`, `errorMessage`).
///
/// The panel therefore writes only [PushNotification.toDraftMap], so saving an
/// edit can never clobber the result of a dispatch that is already in flight.
class FirebasePushRepository implements PushRepository {
  FirebasePushRepository([FirebaseFirestore? firestore, FunctionsService? functions])
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _functions = functions;

  final FirebaseFirestore _firestore;
  final FunctionsService? _functions;

  /// Must match `PUSH_CAMPAIGNS_COLLECTION` in the functions codebase and
  /// `CampaignRepository.collection` in the mobile app.
  static const String _collection = 'push_campaigns';

  /// Name of the callable that performs the send.
  static const String _sendCallable = 'adminSendPush';

  FunctionsService? get _functionsService {
    if (_functions != null) return _functions;
    return Get.isRegistered<FunctionsService>()
        ? Get.find<FunctionsService>()
        : null;
  }

  StorageService? get _storageService {
    return Get.isRegistered<StorageService>()
        ? Get.find<StorageService>()
        : null;
  }

  @override
  Future<List<PushNotification>> fetchCampaigns({int limit = 50}) async {
    AppLoggerHelper.info('[FirebasePushRepository] 📬 Querying campaigns (limit: $limit)...');
    try {
      final snap = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final list = snap.docs
          .map((doc) => PushNotification.fromMap(doc.data(), docId: doc.id))
          .toList();
      AppLoggerHelper.success('FirebasePushRepository', 'Fetched ${list.length} campaigns');
      return list;
    } catch (e) {
      AppLoggerHelper.warning('[FirebasePushRepository] Ordered fetch failed, falling back to unordered: $e');
      final snap = await _firestore.collection(_collection).limit(limit).get();
      final list = snap.docs
          .map((doc) => PushNotification.fromMap(doc.data(), docId: doc.id))
          .toList();
      list.sort((a, b) {
        final aDate = a.createdAt ?? a.sentAt ?? DateTime(1970);
        final bDate = b.createdAt ?? b.sentAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
      AppLoggerHelper.success('FirebasePushRepository', 'Fallback fetched ${list.length} campaigns');
      return list;
    }
  }

  @override
  Future<String> saveDraft(PushNotification campaign) async {
    final adminUid = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().user.value?.uid
        : null;

    final data = campaign.toDraftMap();

    // An id that is not yet in Firestore means this is a new campaign. Let
    // Firestore mint the document id so two admins composing at once cannot
    // collide on a client-generated one.
    final isNew = campaign.id.isEmpty || !await _exists(campaign.id);

    if (isNew) {
      final ref = await _firestore.collection(_collection).add({
        ...data,
        'status': PushStatus.draft.name,
        'sentCount': 0,
        'failedCount': 0,
        'createdBy': ?adminUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLoggerHelper.success('FirebasePushRepository', 'Created campaign draft "${campaign.titleEn}" (${ref.id})');

      AuditService.log(
        module: 'Push Notifications',
        action: AuditAction.created,
        details: 'Created campaign draft "${campaign.titleEn}" (${ref.id})',
      );
      return ref.id;
    }

    await _firestore.collection(_collection).doc(campaign.id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    AppLoggerHelper.success('FirebasePushRepository', 'Updated campaign "${campaign.titleEn}" (${campaign.id})');

    AuditService.log(
      module: 'Push Notifications',
      action: AuditAction.updated,
      details: 'Updated campaign "${campaign.titleEn}" (${campaign.id})',
    );
    return campaign.id;
  }

  @override
  Future<void> deleteCampaign(String id, {String? imageUrl}) async {
    // 1. Delete associated image from Firebase Storage if present
    String? targetImageUrl = imageUrl;
    if (targetImageUrl == null || targetImageUrl.isEmpty) {
      try {
        final docSnap = await _firestore.collection(_collection).doc(id).get();
        if (docSnap.exists) {
          targetImageUrl = docSnap.data()?['imageUrl']?.toString();
        }
      } catch (e) {
        AppLoggerHelper.debug('Could not read campaign before delete: $e');
      }
    }

    if (targetImageUrl != null && targetImageUrl.isNotEmpty) {
      final storage = _storageService;
      if (storage != null) {
        AppLoggerHelper.info('[FirebasePushRepository] 🗑️ Deleting associated campaign image: $targetImageUrl');
        await storage.deleteFile(targetImageUrl);
      }
    }

    // 2. Delete Firestore campaign document
    await _firestore.collection(_collection).doc(id).delete();
    AppLoggerHelper.success('FirebasePushRepository', 'Deleted campaign $id from Firestore and Storage');

    AuditService.log(
      module: 'Push Notifications',
      action: AuditAction.deleted,
      details: 'Deleted campaign $id and its storage assets',
    );
  }

  @override
  Future<DispatchResult> dispatch(PushNotification campaign) async {
    final functions = _functionsService;
    if (functions == null) {
      throw StateError(
        'FunctionsService is not registered — cannot dispatch a campaign.',
      );
    }

    // The campaign must exist server-side first: the function reads the
    // document rather than trusting content from the browser, so an admin
    // cannot use the callable to push arbitrary text.
    final campaignId = await saveDraft(campaign);

    AppLoggerHelper.info('[FirebasePushRepository] ⚡ Invoking $_sendCallable for campaignId: $campaignId');
    final response = await functions.call<Map<dynamic, dynamic>>(
      _sendCallable,
      {'campaignId': campaignId},
    );

    return DispatchResult(
      accepted: _asInt(response['sent']),
      rejected: _asInt(response['failed']),
      targeted: _asInt(response['targeted']),
      pruned: _asInt(response['pruned']),
      messageId: response['messageId']?.toString(),
      audienceLabel: response['audienceLabel']?.toString(),
      error: response['error']?.toString(),
    );
  }

  @override
  Future<void> publishInApp(PushNotification campaign) async {
    // Save first so the published document carries the latest copy, then flip
    // it to `sent` — that is the only state the mobile app's query accepts.
    final campaignId = await saveDraft(campaign);

    await _firestore.collection(_collection).doc(campaignId).update({
      'status': PushStatus.sent.name,
      'sentAt': FieldValue.serverTimestamp(),
      // No FCM call happened, so there are no per-device counts to report.
      // Leaving them at zero is honest; the status is what makes it live.
      'sentCount': 0,
      'failedCount': 0,
      'errorMessage': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    AppLoggerHelper.info(
      '[FirebasePushRepository] 📣 Published in-app campaign "${campaign.titleEn}" ($campaignId)',
    );

    AuditService.log(
      module: 'Push Notifications',
      action: AuditAction.updated,
      details: 'Published in-app campaign "${campaign.titleEn}" ($campaignId)',
    );
  }

  Future<bool> _exists(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
