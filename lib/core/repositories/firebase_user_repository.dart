import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/core/services/storage_service.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

/// Production UserRepository reading and writing to Cloud Firestore collection `users`.
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final StorageService? _storageService;

  FirebaseUserRepository([FirebaseFirestore? firestore, StorageService? storageService])
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService;

  StorageService get _storage =>
      _storageService ??
      (Get.isRegistered<StorageService>() ? Get.find<StorageService>() : StorageService());

  static const String _collection = 'users';

  @override
  Future<List<AppUser>> seedUsers() => fetchUsers();

  @override
  Future<List<AppUser>> fetchUsers({int limit = 150}) async {
    AppLoggerHelper.info('[FirebaseUserRepository] 👥 Querying users (limit: $limit)...');
    try {
      final snap = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final list = snap.docs
          .map((doc) => AppUser.fromMap(doc.data(), docId: doc.id))
          .toList();
      AppLoggerHelper.success('FirebaseUserRepository', 'Fetched ${list.length} users from Firestore');
      return list;
    } catch (e) {
      AppLoggerHelper.warning('[FirebaseUserRepository] Ordered fetch failed, falling back to unordered query: $e');
      final snap = await _firestore.collection(_collection).limit(limit).get();
      final list = snap.docs
          .map((doc) => AppUser.fromMap(doc.data(), docId: doc.id))
          .toList();
      list.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
      AppLoggerHelper.success('FirebaseUserRepository', 'Fallback fetched ${list.length} users');
      return list;
    }
  }

  @override
  Future<AppUser?> getUser(String uid) async {
    AppLoggerHelper.info('[FirebaseUserRepository] 🔍 Fetching user doc: $uid');
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      AppLoggerHelper.warning('[FirebaseUserRepository] User $uid not found');
      return null;
    }
    return AppUser.fromMap(doc.data()!, docId: doc.id);
  }

  @override
  Future<void> updateUserStatus(String uid, UserStatus status) async {
    await _firestore.collection(_collection).doc(uid).set({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    AppLoggerHelper.success('FirebaseUserRepository', 'Updated user $uid status to ${status.name}');

    AuditService.log(
      module: 'User Management',
      action: AuditAction.updated,
      details: 'Updated status of user $uid to ${status.name.toUpperCase()}',
    );
  }

  @override
  Future<void> updateUserPlan(String uid, UserPlan plan) async {
    await _firestore.collection(_collection).doc(uid).set({
      'plan': plan.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    AppLoggerHelper.success('FirebaseUserRepository', 'Updated user $uid plan to ${plan.name}');

    AuditService.log(
      module: 'User Management',
      action: AuditAction.updated,
      details: 'Updated subscription plan of user $uid to ${plan.name.toUpperCase()}',
    );
  }

  @override
  Future<void> deleteUser(String uid) async {
    AppLoggerHelper.info('[FirebaseUserRepository] 🗑️ Deleting user $uid and their storage assets...');

    // 1. Check user document to extract custom avatar or uploaded photo
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        final photoUrl = data?['photoUrl']?.toString() ?? data?['avatarUrl']?.toString();
        if (photoUrl != null && photoUrl.isNotEmpty && photoUrl.startsWith('http')) {
          await _storage.deleteFile(photoUrl);
        }
      }
    } catch (e) {
      AppLoggerHelper.warning('Error reading user $uid before delete: $e');
    }

    // 2. Clean up user upload folder from Firebase Storage
    try {
      await _storage.deleteFolder('user_uploads/$uid');
    } catch (e) {
      AppLoggerHelper.warning('User storage cleanup warning ($uid): $e');
    }

    // 3. Delete Firestore user document
    await _firestore.collection(_collection).doc(uid).delete();
    AppLoggerHelper.success('FirebaseUserRepository', 'Deleted user document: $uid from Firestore and Storage');

    AuditService.log(
      module: 'User Management',
      action: AuditAction.deleted,
      details: 'Permanently deleted user account $uid and storage assets',
    );
  }
}
