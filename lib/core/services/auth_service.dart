import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/firestore_service.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
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
        AppLoggerHelper.info('[AuthService] 🚪 No active admin session');
        return;
      }

      AppLoggerHelper.info('[AuthService] 👤 Session detected for ${fbUser.email} (${fbUser.uid})');
      await _loadUserProfile(fbUser);
      initializing.value = false;
    });

    FirebaseAuth.instance.idTokenChanges().listen((fbUser) async {
      if (fbUser != null && user.value != null) {
        AppLoggerHelper.info('[AuthService] 🔄 ID token refreshed for ${fbUser.email}');
        await _loadUserProfile(fbUser);
      }
    });
  }

  Future<void> _loadUserProfile(User fbUser) async {
    AdminRole? claimRole;
    try {
      final tokenResult = await fbUser.getIdTokenResult();
      final claimRoleStr = tokenResult.claims?['role'];
      if (claimRoleStr != null) {
        claimRole = AdminRole.fromString(claimRoleStr);
      }

      // Read admin document from admins/{uid}
      final doc =
          await FirestoreService.db.collection('admins').doc(fbUser.uid).get();
      final data = doc.data();

      // Check if admin account was deactivated
      if (data != null && data['active'] == false) {
        AppLoggerHelper.warning('[AuthService] ⛔ Admin account ${fbUser.uid} is deactivated');
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
      AppLoggerHelper.success(
        'AuthService',
        'Admin profile loaded: ${user.value?.name} (${user.value?.email}) [Role: ${user.value?.role.label}]',
      );
    } catch (e) {
      AppLoggerHelper.warning('[AuthService] Failed to load full profile for ${fbUser.uid}: $e');
      user.value = AdminUser(
        uid: fbUser.uid,
        name: fbUser.displayName ??
            (fbUser.email?.split('@').first ?? 'Admin'),
        email: fbUser.email ?? '',
        role: claimRole ?? AdminRole.viewer,
      );
    }
  }

  /// Sign in with Email and Password
  Future<AuthResult> login(String email, String password) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      return const AuthResult.failure('Please provide both email and password.');
    }

    AppLoggerHelper.info('[AuthService] 🔐 Admin login attempt for: $cleanEmail');
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      if (cred.user == null) {
        AppLoggerHelper.failure('AuthService', 'User not found for $cleanEmail');
        return const AuthResult.failure('Unable to sign in. User not found.');
      }

      await _loadUserProfile(cred.user!);

      if (user.value == null) {
        AppLoggerHelper.failure('AuthService', 'Account deactivated or unauthorized for $cleanEmail');
        return const AuthResult.failure(
          'This account is deactivated or unauthorized.',
        );
      }

      AppLoggerHelper.success('AuthService', 'Admin login successful: $cleanEmail (${user.value?.role.label})');
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseError(e);
      AppLoggerHelper.warning('[AuthService] Firebase login error for $cleanEmail: $msg (${e.code})');
      return AuthResult.failure(msg);
    } catch (e, st) {
      AppLoggerHelper.failure('AuthService', 'Sign in failed for $cleanEmail: $e', error: e, stackTrace: st);
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
