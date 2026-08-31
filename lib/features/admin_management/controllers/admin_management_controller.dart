import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/admin_repository.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/admin_management/models/admin_profile.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';

class AdminManagementController extends GetxController {
  final AdminRepository adminRepo = Get.find<AdminRepository>();
  final AuthService authService = Get.find<AuthService>();

  final admins = <AdminProfile>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  bool get canManageAdmins =>
      authService.user.value?.role == AdminRole.superAdmin;

  String? get currentUid => authService.user.value?.uid;

  @override
  void onInit() {
    super.onInit();
    loadAdmins();
  }

  Future<void> loadAdmins() async {
    isLoading.value = true;
    try {
      final list = await adminRepo.listAdmins();
      admins.assignAll(list);
    } catch (e) {
      debugPrint('Error loading admins: $e');
      AppToast.error('Failed to load admins', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<InviteAdminResult?> invite({
    required String name,
    required String email,
    required AdminRole role,
    String? tempPassword,
  }) async {
    isSubmitting.value = true;
    try {
      final result = await adminRepo.inviteAdmin(
        name: name,
        email: email,
        role: role,
        tempPassword: tempPassword,
      );

      await loadAdmins();
      return result;
    } catch (e) {
      debugPrint('Error inviting admin: $e');
      AppToast.error('Invite Failed', e.toString());
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> setRole(String uid, AdminRole newRole) async {
    final target = admins.firstWhereOrNull((a) => a.uid == uid);
    if (target == null) return false;
    if (target.role == newRole) return true;

    // Last Super Admin Demotion Guard
    if (target.role == AdminRole.superAdmin && newRole != AdminRole.superAdmin) {
      final activeSuperAdmins = admins
          .where((a) => a.role == AdminRole.superAdmin && a.active)
          .length;
      if (activeSuperAdmins <= 1) {
        AppToast.error(
          'Action Blocked',
          'Cannot demote the last active Super Admin.',
        );
        return false;
      }
    }

    try {
      await adminRepo.setRole(targetUid: uid, role: newRole);
      final index = admins.indexWhere((a) => a.uid == uid);
      if (index >= 0) {
        admins[index] = admins[index].copyWith(role: newRole);
      }
      AppToast.success(
        'Role Updated',
        'Updated role for ${target.name} to ${newRole.label}.',
      );
      return true;
    } catch (e) {
      debugPrint('Error setting role: $e');
      AppToast.error('Failed to Update Role', e.toString());
      return false;
    }
  }

  Future<bool> toggleActive(String uid) async {
    final target = admins.firstWhereOrNull((a) => a.uid == uid);
    if (target == null) return false;

    // Self-Deactivation Guard
    if (currentUid != null && currentUid == uid && target.active) {
      AppToast.error(
        'Action Blocked',
        'You cannot deactivate your own admin account.',
      );
      return false;
    }

    // Last Super Admin Deactivation Guard
    if (target.active && target.role == AdminRole.superAdmin) {
      final activeSuperAdmins = admins
          .where((a) => a.role == AdminRole.superAdmin && a.active)
          .length;
      if (activeSuperAdmins <= 1) {
        AppToast.error(
          'Action Blocked',
          'Cannot deactivate the last active Super Admin.',
        );
        return false;
      }
    }

    final newActive = !target.active;
    try {
      await adminRepo.setActive(uid, newActive);
      final index = admins.indexWhere((a) => a.uid == uid);
      if (index >= 0) {
        admins[index] = admins[index].copyWith(active: newActive);
      }
      AppToast.success(
        newActive ? 'Admin Enabled' : 'Admin Disabled',
        '${target.name} has been ${newActive ? 'enabled' : 'disabled'}.',
      );
      return true;
    } catch (e) {
      debugPrint('Error toggling active status: $e');
      AppToast.error('Failed to Update Status', e.toString());
      return false;
    }
  }
}
