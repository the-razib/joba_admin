import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/push_repository.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';

class PushController extends GetxController {
  final PushRepository repo = Get.find();

  final all = <PushNotification>[].obs;
  final loading = true.obs;

  /// Campaign ids currently being dispatched, so the UI can disable their
  /// actions instead of letting an impatient admin fire twice.
  final dispatching = <String>{}.obs;

  /// Last dispatch error, surfaced by the screen.
  final lastError = RxnString();

  /// `null` = no channel filter.
  final channelFilter = Rxn<NotificationChannel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    AppLoggerHelper.info('[PushController] 🔔 Fetching push notification campaigns...');
    try {
      final campaigns = await repo.fetchCampaigns();
      all.assignAll(campaigns);
      AppLoggerHelper.success('PushController', 'Loaded ${all.length} push notification campaigns');
    } catch (e, st) {
      AppLoggerHelper.failure('PushController', 'Failed to fetch campaigns: $e', error: e, stackTrace: st);
      lastError.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void setChannelFilter(NotificationChannel? c) => channelFilter.value = c;

  /// A campaign sent to `both` belongs in the Push list and the In-App list,
  /// so filtering matches on capability rather than equality.
  List<PushNotification> get visible {
    final f = channelFilter.value;
    if (f == null) return all.toList();
    return all.where((p) {
      return switch (f) {
        NotificationChannel.push => p.channel.hasPush,
        NotificationChannel.inApp => p.channel.hasInApp,
        NotificationChannel.both => p.channel == NotificationChannel.both,
      };
    }).toList();
  }

  List<PushNotification> get sent =>
      all.where((p) => p.status.isDelivered).toList();

  int get sentCampaignCount => sent.length;

  /// Devices FCM accepted across every sent campaign. A real figure, unlike the
  /// previous mock "delivered" total.
  int get totalAccepted => sent.fold(0, (a, p) => a + p.sentCount);

  /// Devices FCM rejected across every sent campaign — almost entirely stale
  /// tokens from uninstalled apps.
  int get totalRejected => sent.fold(0, (a, p) => a + p.failedCount);

  /// Share of attempted devices FCM accepted.
  ///
  /// NOT an open rate. Opens and deliveries to the handset are not obtainable
  /// from FCM's HTTP v1 responses; they need an Analytics/BigQuery export, which
  /// this project does not have yet.
  double get acceptanceRate {
    final attempted = totalAccepted + totalRejected;
    return attempted == 0 ? 0 : totalAccepted / attempted * 100;
  }

  int get failedCampaignCount =>
      all.where((p) => p.status == PushStatus.failed).length;

  int countWithImage() => all.where((p) => p.hasImage).length;

  bool isDispatching(String id) => dispatching.contains(id);

  /// Delete a campaign from Firestore, its storage image, and the local list.
  Future<void> remove(String id) async {
    try {
      final matchIndex = all.indexWhere((p) => p.id == id);
      final imageUrl = matchIndex >= 0 ? all[matchIndex].imageUrl : null;
      await repo.deleteCampaign(id, imageUrl: imageUrl);
      all.removeWhere((p) => p.id == id);
    } catch (e) {
      lastError.value = e.toString();
    }
  }

  /// Dispatch a draft (or retry a failed campaign).
  ///
  /// Returns the result so the caller can report real counts. The list is
  /// refreshed from Firestore afterwards because the Cloud Function — not this
  /// client — owns `status`, `sentCount` and `failedCount`.
  Future<DispatchResult?> sendDraft(String id) async {
    final index = all.indexWhere((p) => p.id == id);
    if (index < 0) return null;

    final campaign = all[index];
    // Guard here as well as in the UI: the detail panel's Send button is
    // reachable for drafts saved before a validation rule existed.
    if (!campaign.canSend) return null;
    if (dispatching.contains(id)) return null;

    return _dispatch(campaign);
  }

  /// Send an already-sent campaign again.
  Future<DispatchResult?> resend(String id) async {
    final index = all.indexWhere((p) => p.id == id);
    if (index < 0) return null;
    if (dispatching.contains(id)) return null;
    return _dispatch(all[index]);
  }

  Future<DispatchResult?> _dispatch(PushNotification campaign) async {
    lastError.value = null;
    dispatching.add(campaign.id);
    AppLoggerHelper.info('[PushController] 🚀 Dispatching campaign "${campaign.titleEn}" (${campaign.id}) [Audience: ${campaign.audience.name}, Channel: ${campaign.channel.name}]');
    try {
      // In-app-only campaigns are not pushed anywhere — the mobile app reads
      // published documents and renders them itself. Calling the FCM function
      // for one is rejected by design, so publish instead of dispatching.
      if (campaign.channel == NotificationChannel.inApp) {
        await repo.publishInApp(campaign);
        AppLoggerHelper.success(
          'PushController',
          'Published in-app campaign "${campaign.titleEn}" — visible on next app open',
        );
        return const DispatchResult.published();
      }

      final result = await repo.dispatch(campaign);
      if (result.error != null) {
        lastError.value = result.error;
        AppLoggerHelper.warning('PushController', 'Dispatch failed for ${campaign.id}: ${result.error}');
      } else {
        AppLoggerHelper.success(
          'PushController',
          'Dispatched "${campaign.titleEn}": Accepted: ${result.accepted}, Rejected: ${result.rejected}',
        );
      }
      return result;
    } catch (e, st) {
      lastError.value = e.toString();
      AppLoggerHelper.failure('PushController', 'Dispatch error for ${campaign.id}: $e', error: e, stackTrace: st);
      return null;
    } finally {
      dispatching.remove(campaign.id);
      // Pull the authoritative delivery state back.
      await load();
    }
  }

  /// Persist a draft, optionally dispatching it immediately.
  ///
  /// Returns the dispatch result when [send] is true, so the caller can report
  /// real counts rather than a generic "queued" message. Returns null when the
  /// campaign was only saved, or when saving itself failed — check [lastError].
  Future<DispatchResult?> save(
    PushNotification n, {
    required bool send,
  }) async {
    lastError.value = null;
    AppLoggerHelper.info('[PushController] 💾 Saving campaign "${n.titleEn}" (Send immediately: $send)...');
    try {
      final id = await repo.saveDraft(n);
      AppLoggerHelper.success('PushController', 'Campaign draft saved with id: $id');
      await load();
      if (!send) return null;
      return await sendDraft(id);
    } catch (e, st) {
      lastError.value = e.toString();
      AppLoggerHelper.failure('PushController', 'Failed to save campaign draft: $e', error: e, stackTrace: st);
      return null;
    }
  }

  /// Build an unsaved campaign from composer input.
  ///
  /// New campaigns carry an empty id: the backend assigns one on save, so two
  /// admins composing at the same time cannot collide on a client-side id.
  PushNotification draft({
    required String titleBn,
    required String titleEn,
    required String bodyBn,
    required String bodyEn,
    required PushAudience audience,
    required NotificationChannel channel,
    required InAppLayout inAppLayout,
    String? id,
    String? imageUrl,
    String? actionLabelBn,
    String? actionLabelEn,
    String? actionUrl,
  }) => PushNotification(
    id: id ?? '',
    titleBn: titleBn,
    titleEn: titleEn,
    bodyBn: bodyBn,
    bodyEn: bodyEn,
    audience: audience,
    channel: channel,
    inAppLayout: inAppLayout,
    imageUrl: imageUrl,
    actionLabelBn: actionLabelBn,
    actionLabelEn: actionLabelEn,
    actionUrl: actionUrl,
  );
}
