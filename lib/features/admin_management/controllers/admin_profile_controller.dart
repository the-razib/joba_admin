import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/firestore_service.dart';
import 'package:joba_admin/core/services/storage_service.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';

class AdminProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  StorageService get storageService =>
      Get.isRegistered<StorageService>()
          ? Get.find<StorageService>()
          : StorageService();

  final isUploadingPhoto = false.obs;
  final isSavingName = false.obs;
  final isChangingPassword = false.obs;

  final nameFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscureCurrent = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  AdminUser? get user => authService.user.value;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void onClose() {
    nameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Pick and upload a new administrator profile photo
  Future<void> pickAndUploadPhoto() async {
    final currentUser = user;
    if (currentUser == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        AppToast.error('Upload Error', 'Could not read image data.');
        return;
      }

      // Check 5 MB limit
      if (bytes.length > 5 * 1024 * 1024) {
        AppToast.warning('File Too Large', 'Please select an image smaller than 5 MB.');
        return;
      }

      isUploadingPhoto.value = true;
      AppLoggerHelper.info('[AdminProfile] 📷 Uploading admin profile photo for ${currentUser.email}');

      final ext = file.extension?.toLowerCase() ?? 'jpg';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fullPath = 'admin_uploads/${currentUser.uid}/profile_$timestamp.$ext';

      // 1. Upload bytes to Firebase Storage
      final downloadUrl = await storageService.uploadBytesToPath(
        fullPath: fullPath,
        bytes: bytes,
      );

      // 2. Delete old photo from Storage if it exists
      final oldUrl = currentUser.photoUrl;
      if (oldUrl != null && oldUrl.isNotEmpty) {
        await storageService.deleteFile(oldUrl);
      }

      // 3. Update Firebase Auth user
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        await fbUser.updatePhotoURL(downloadUrl);
      }

      // 4. Update Firestore admin record
      await FirestoreService.db
          .collection('admins')
          .doc(currentUser.uid)
          .set({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 5. Update reactive state in AuthService
      authService.user.value = currentUser.copyWith(photoUrl: downloadUrl);

      // 6. Audit log
      AuditService.log(
        module: 'Admin Profile',
        action: AuditAction.updated,
        details: 'Admin updated profile photo (${currentUser.email})',
        status: AuditStatus.success,
        adminName: currentUser.name,
      );

      AppToast.success('Photo Updated', 'Your profile photo has been updated.');
      AppLoggerHelper.success('AdminProfile', 'Profile photo updated for ${currentUser.email}');
    } catch (e, st) {
      AppLoggerHelper.failure('AdminProfile', 'Failed to upload photo: $e', error: e, stackTrace: st);
      AppToast.error('Upload Failed', 'Could not update profile photo: $e');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Remove administrator profile photo
  Future<void> deletePhoto() async {
    final currentUser = user;
    if (currentUser == null) return;
    final oldUrl = currentUser.photoUrl;
    if (oldUrl == null || oldUrl.isEmpty) return;

    try {
      isUploadingPhoto.value = true;
      AppLoggerHelper.info('[AdminProfile] 🗑️ Removing profile photo for ${currentUser.email}');

      // 1. Delete from Firebase Storage
      await storageService.deleteFile(oldUrl);

      // 2. Update Firebase Auth user
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        await fbUser.updatePhotoURL(null);
      }

      // 3. Update Firestore admin document
      await FirestoreService.db
          .collection('admins')
          .doc(currentUser.uid)
          .update({
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Update reactive state in AuthService
      authService.user.value = currentUser.copyWith(clearPhoto: true);

      // 5. Audit log
      AuditService.log(
        module: 'Admin Profile',
        action: AuditAction.deleted,
        details: 'Admin removed profile photo (${currentUser.email})',
        status: AuditStatus.success,
        adminName: currentUser.name,
      );

      AppToast.info('Photo Removed', 'Profile photo removed.');
      AppLoggerHelper.success('AdminProfile', 'Profile photo removed for ${currentUser.email}');
    } catch (e, st) {
      AppLoggerHelper.failure('AdminProfile', 'Failed to remove photo: $e', error: e, stackTrace: st);
      AppToast.error('Remove Failed', 'Could not remove photo: $e');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Save administrator display name
  Future<void> saveName() async {
    final currentUser = user;
    if (currentUser == null) return;

    if (!(nameFormKey.currentState?.validate() ?? false)) return;

    final newName = nameController.text.trim();
    if (newName == currentUser.name) {
      AppToast.info('No Changes', 'Display name is already set to "$newName".');
      return;
    }

    try {
      isSavingName.value = true;
      AppLoggerHelper.info('[AdminProfile] ✏️ Renaming admin ${currentUser.uid} to "$newName"');

      // 1. Update Firebase Auth user
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        await fbUser.updateDisplayName(newName);
      }

      // 2. Update Firestore admin document
      await FirestoreService.db
          .collection('admins')
          .doc(currentUser.uid)
          .set({
        'name': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Update reactive state in AuthService
      authService.user.value = currentUser.copyWith(name: newName);

      // 4. Audit log
      AuditService.log(
        module: 'Admin Profile',
        action: AuditAction.updated,
        details: 'Admin changed display name from "${currentUser.name}" to "$newName"',
        status: AuditStatus.success,
        adminName: newName,
      );

      AppToast.success('Name Updated', 'Display name updated successfully.');
      AppLoggerHelper.success('AdminProfile', 'Display name updated to "$newName"');
    } catch (e, st) {
      AppLoggerHelper.failure('AdminProfile', 'Failed to update name: $e', error: e, stackTrace: st);
      AppToast.error('Update Failed', 'Could not update name: $e');
    } finally {
      isSavingName.value = false;
    }
  }

  /// Change administrator password securely with re-authentication
  Future<bool> changePassword() async {
    final currentUser = user;
    final fbUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || fbUser == null || fbUser.email == null) {
      AppToast.error('Authentication Error', 'No active session found.');
      return false;
    }

    if (!(passwordFormKey.currentState?.validate() ?? false)) return false;

    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      AppToast.warning('Mismatch', 'New password and confirmation do not match.');
      return false;
    }

    if (newPassword == currentPassword) {
      AppToast.warning('Same Password', 'New password cannot be the same as current password.');
      return false;
    }

    if (newPassword.length < 8) {
      AppToast.warning('Password Too Short', 'New password must be at least 8 characters long.');
      return false;
    }

    try {
      isChangingPassword.value = true;
      AppLoggerHelper.info('[AdminProfile] 🔒 Admin password change request for ${currentUser.email}');

      // 1. Re-authenticate with current credentials
      final credential = EmailAuthProvider.credential(
        email: fbUser.email!,
        password: currentPassword,
      );
      await fbUser.reauthenticateWithCredential(credential);

      // 2. Update to new password
      await fbUser.updatePassword(newPassword);

      // 3. Clear sensitive text controllers
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // 4. Audit log
      AuditService.log(
        module: 'Admin Security',
        action: AuditAction.updated,
        details: 'Admin changed password successfully (${currentUser.email})',
        status: AuditStatus.success,
        adminName: currentUser.name,
      );

      AppToast.success('Password Updated', 'Your password has been changed successfully.');
      AppLoggerHelper.success('AdminProfile', 'Password successfully changed for ${currentUser.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      AppLoggerHelper.warning('[AdminProfile] Firebase auth error on password update: ${e.code} - ${e.message}');
      final msg = switch (e.code) {
        'wrong-password' || 'invalid-credential' => 'Current password does not match.',
        'weak-password' => 'Password is too weak. Please use a stronger password.',
        'requires-recent-login' => 'Session expired. Please log in again to change password.',
        _ => e.message ?? 'Failed to update password.',
      };
      AppToast.error('Password Error', msg);
      return false;
    } catch (e, st) {
      AppLoggerHelper.failure('AdminProfile', 'Unexpected error on password update: $e', error: e, stackTrace: st);
      AppToast.error('Error', 'An unexpected error occurred: $e');
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }
}
