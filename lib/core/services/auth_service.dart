import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/firestore_service.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';

/// Result object for authentication attempts
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  const AuthResult.success()
      : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage) : isSuccess = false;
}

/// Firebase Auth Service with persistent session handling and Custom Claims role enforcement.
class AuthService extends GetxService {
  final user = Rxn<AdminUser>();
  final initializing = true.obs;

  bool get isAuthenticated => user.value != null;
  bool get canManageContent => user.value?.canManageContent ?? false;
  bool get canManageAdmins => user.value?.canManageAdmins ?? false;

  @override
  void onInit() {
    super.onInit();
    try {
      _initAuthListener();
    } catch (_) {
      // Graceful fallback for headless unit/widget tests
      initializing.value = false;
    }
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((fbUser) async {
      if (fbUser == null) {
        user.value = null;
        initializing.value = false;
        return;
      }

      await _loadUserProfile(fbUser);
      initializing.value = false;
    });

    FirebaseAuth.instance.idTokenChanges().listen((fbUser) async {
      if (fbUser != null && user.value != null) {
        await _loadUserProfile(fbUser);
      }
    });
  }

  Future<void> _loadUserProfile(User fbUser) async {
    try {
      final tokenResult = await fbUser.getIdTokenResult();
      final claimRoleStr = tokenResult.claims?['role'];
      AdminRole? claimRole;
      if (claimRoleStr != null) {
        claimRole = AdminRole.fromString(claimRoleStr);
      }

      // Read admin document from admins/{uid}
      final doc =
          await FirestoreService.db.collection('admins').doc(fbUser.uid).get();
      final data = doc.data();

      // Check if admin account was deactivated
      if (data != null && data['active'] == false) {
        await FirebaseAuth.instance.signOut();
        user.value = null;
        AppToast.error(
          'Account Deactivated',
          'Your admin account has been deactivated by an administrator.',
        );
        return;
      }

      user.value = AdminUser.fromFirebase(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName,
        photoUrl: fbUser.photoURL,
        firestoreData: data,
        roleFromClaim: claimRole,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [AuthService] Failed to load full profile for ${fbUser.uid}: $e');
      }
      user.value = AdminUser(
        uid: fbUser.uid,
        name: fbUser.displayName ??
            (fbUser.email?.split('@').first ?? 'Admin'),
        email: fbUser.email ?? '',
        role: AdminRole.superAdmin,
      );
    }
  }

  /// Sign in with Email and Password
  Future<AuthResult> login(String email, String password) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      return const AuthResult.failure('Please provide both email and password.');
    }

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      if (cred.user == null) {
        return const AuthResult.failure('Unable to sign in. User not found.');
      }

      await _loadUserProfile(cred.user!);

      if (user.value == null) {
        return const AuthResult.failure(
          'This account is deactivated or unauthorized.',
        );
      }

      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('Sign in failed: $e');
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No admin account found with this email.',
      'wrong-password' ||
      'invalid-credential' =>
        'Incorrect email or password. Please try again.',
      'user-disabled' =>
        'This account has been disabled by an administrator.',
      'too-many-requests' =>
        'Too many unsuccessful login attempts. Please try again later.',
      'invalid-email' => 'Please enter a valid email address.',
      'network-request-failed' =>
        'Network error. Please check your internet connection.',
      _ => e.message ?? 'Authentication failed (${e.code}).',
    };
  }

  /// Sign out
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    user.value = null;
  }
}
