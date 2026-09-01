import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

/// Production UserRepository reading and writing to Cloud Firestore collection `users`.
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'users';

  @override
  Future<List<AppUser>> seedUsers() => fetchUsers();

  @override
  Future<List<AppUser>> fetchUsers({int limit = 150}) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map((doc) => AppUser.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (_) {
      // Fallback query without orderBy to ensure zero index failures
      final snap = await _firestore.collection(_collection).limit(limit).get();
      final list = snap.docs
          .map((doc) => AppUser.fromMap(doc.data(), docId: doc.id))
          .toList();
      list.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
      return list;
    }
  }

  @override
  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!, docId: doc.id);
  }

  @override
  Future<void> updateUserStatus(String uid, UserStatus status) async {
    await _firestore.collection(_collection).doc(uid).set({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

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

    AuditService.log(
      module: 'User Management',
      action: AuditAction.updated,
      details: 'Updated subscription plan of user $uid to ${plan.name.toUpperCase()}',
    );
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _firestore.collection(_collection).doc(uid).delete();

    AuditService.log(
      module: 'User Management',
      action: AuditAction.deleted,
      details: 'Permanently deleted user account $uid',
    );
  }
}
