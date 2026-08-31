import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/functions_service.dart';
import 'package:joba_admin/features/admin_management/models/admin_profile.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:uuid/uuid.dart';

class InviteAdminResult {
  final String uid;
  final String email;
  final AdminRole role;
  final String tempPassword;

  const InviteAdminResult({
    required this.uid,
    required this.email,
    required this.role,
    required this.tempPassword,
  });
}

abstract class AdminRepository {
  Future<List<AdminProfile>> listAdmins();
  Future<void> setActive(String uid, bool active);
  Future<InviteAdminResult> inviteAdmin({
    required String name,
    required String email,
    required AdminRole role,
    String? tempPassword,
  });
  Future<void> setRole({
    required String targetUid,
    required AdminRole role,
  });
}

class FirebaseAdminRepository implements AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<AdminProfile>> listAdmins() async {
    try {
      final snap = await _firestore
          .collection('admins')
          .orderBy('createdAt', descending: true)
          .get();

      if (snap.docs.isEmpty) {
        final allDocs = await _firestore.collection('admins').get();
        return allDocs.docs
            .map((doc) => AdminProfile.fromMap(doc.data(), docId: doc.id))
            .toList();
      }

      return snap.docs
          .map((doc) => AdminProfile.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error listing admins from Firestore: $e');
      final fallback = await _firestore.collection('admins').get();
      return fallback.docs
          .map((doc) => AdminProfile.fromMap(doc.data(), docId: doc.id))
          .toList();
    }
  }

  @override
  Future<void> setActive(String uid, bool active) async {
    await _firestore.collection('admins').doc(uid).set({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<InviteAdminResult> inviteAdmin({
    required String name,
    required String email,
    required AdminRole role,
    String? tempPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final password = (tempPassword != null && tempPassword.trim().isNotEmpty)
        ? tempPassword.trim()
        : 'Joba#${const Uuid().v4().substring(0, 8)}!';

    String? createdUid;

    // 1. Direct Auth User Creation via temporary secondary FirebaseApp instance
    // (This guarantees the current logged-in Super Admin session is NEVER disturbed)
    try {
      final tempAppName = 'AdminAuthCreator_${DateTime.now().millisecondsSinceEpoch}';
      final tempApp = await Firebase.initializeApp(
        name: tempAppName,
        options: Firebase.app().options,
      );
      try {
        final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        final cred = await tempAuth.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        createdUid = cred.user?.uid;
        if (cred.user != null) {
          await cred.user!.updateDisplayName(name);
        }
      } finally {
        await tempApp.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account with email "$normalizedEmail" already exists in Firebase.');
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak. Please use at least 6 characters.');
      } else {
        throw Exception(e.message ?? 'Failed to create user in Firebase Auth.');
      }
    } catch (e) {
      debugPrint('Direct Auth Creation note: $e');
    }

    // Fallback: If direct creation couldn't get a UID, try Cloud Function if available
    if (createdUid == null || createdUid.isEmpty) {
      try {
        if (Get.isRegistered<FunctionsService>()) {
          final res = await Get.find<FunctionsService>().call<Map<dynamic, dynamic>>(
            'adminInviteAdmin',
            {
              'name': name,
              'email': normalizedEmail,
              'role': role.name,
              'tempPassword': password,
            },
          );
          createdUid = res['uid']?.toString();
        }
      } catch (err) {
        debugPrint('Cloud Function invite fallback note: $err');
      }
    }

    final finalUid = createdUid ?? const Uuid().v4();

    // 2. Save Admin profile document into Firestore admins collection
    await _firestore.collection('admins').doc(finalUid).set({
      'uid': finalUid,
      'name': name,
      'email': normalizedEmail,
      'role': role.name,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 3. Write audit log entry
    try {
      String currentAdminUid = 'superAdmin';
      String currentAdminEmail = '';
      String currentAdminRole = 'superAdmin';
      if (Get.isRegistered<AuthService>()) {
        final cur = Get.find<AuthService>().user.value;
        if (cur != null) {
          currentAdminUid = cur.uid;
          currentAdminEmail = cur.email;
          currentAdminRole = cur.role.name;
        }
      }

      await _firestore.collection('audit_logs').add({
        'adminUid': currentAdminUid,
        'adminEmail': currentAdminEmail,
        'adminRole': currentAdminRole,
        'action': 'create',
        'module': 'Admin Management',
        'targetId': finalUid,
        'summary': 'Created admin $normalizedEmail as ${role.label}',
        'details': 'Name: $name, Email: $normalizedEmail, Role: ${role.label}',
        'status': 'success',
        'time': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}

    return InviteAdminResult(
      uid: finalUid,
      email: normalizedEmail,
      role: role,
      tempPassword: password,
    );
  }

  @override
  Future<void> setRole({
    required String targetUid,
    required AdminRole role,
  }) async {
    // 1. Direct Firestore update
    await _firestore.collection('admins').doc(targetUid).set({
      'role': role.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Cloud Function sync for Custom Claims (best effort)
    try {
      if (Get.isRegistered<FunctionsService>()) {
        await Get.find<FunctionsService>().call('adminSetRole', {
          'targetUid': targetUid,
          'role': role.name,
        });
      }
    } catch (e) {
      debugPrint('Cloud Function setRole note: $e');
    }
  }
}

class MockAdminRepository implements AdminRepository {
  final List<AdminProfile> _admins = [];

  MockAdminRepository() {
    final now = DateTime.now();
    _admins.addAll([
      AdminProfile(
        uid: 'adm-001',
        name: 'Md. Razib Hasan',
        email: 'admin@joba.app',
        role: AdminRole.superAdmin,
        lastActive: now.subtract(const Duration(minutes: 4)),
        active: true,
      ),
      AdminProfile(
        uid: 'adm-002',
        name: 'Farha Islam',
        email: 'editor@joba.app',
        role: AdminRole.editor,
        lastActive: now.subtract(const Duration(hours: 2)),
        active: true,
      ),
      AdminProfile(
        uid: 'adm-003',
        name: 'Sakib Ahmed',
        email: 'viewer@joba.app',
        role: AdminRole.viewer,
        lastActive: now.subtract(const Duration(days: 1)),
        active: true,
      ),
      AdminProfile(
        uid: 'adm-004',
        name: 'Tanvir Hasan',
        email: 'tanvir@joba.app',
        role: AdminRole.editor,
        lastActive: now.subtract(const Duration(days: 3)),
        active: false,
      ),
      AdminProfile(
        uid: 'adm-005',
        name: 'Moumita Rahi',
        email: 'moumita@joba.app',
        role: AdminRole.viewer,
        lastActive: now.subtract(const Duration(hours: 26)),
        active: true,
      ),
    ]);
  }

  @override
  Future<List<AdminProfile>> listAdmins() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.from(_admins);
  }

  @override
  Future<void> setActive(String uid, bool active) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _admins.indexWhere((a) => a.uid == uid);
    if (index >= 0) {
      _admins[index] = _admins[index].copyWith(active: active);
    }
  }

  @override
  Future<InviteAdminResult> inviteAdmin({
    required String name,
    required String email,
    required AdminRole role,
    String? tempPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final generatedPass = tempPassword ?? 'Joba#9kX2pL8!';
    final uid = 'adm-${const Uuid().v4().substring(0, 6)}';
    final profile = AdminProfile(
      uid: uid,
      name: name,
      email: email,
      role: role,
      lastActive: DateTime.now(),
      active: true,
    );
    _admins.insert(0, profile);
    return InviteAdminResult(
      uid: uid,
      email: email,
      role: role,
      tempPassword: generatedPass,
    );
  }

  @override
  Future<void> setRole({
    required String targetUid,
    required AdminRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _admins.indexWhere((a) => a.uid == targetUid);
    if (index >= 0) {
      _admins[index] = _admins[index].copyWith(role: role);
    }
  }
}
