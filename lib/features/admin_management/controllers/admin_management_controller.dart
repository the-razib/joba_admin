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
  final page = 1.obs;
  final pageSize = 10.obs;

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

  List<AdminProfile> get paginated {
    final list = admins.toList();
    final start = (page.value - 1) * pageSize.value;
    if (start >= list.length) {
      if (list.isEmpty) return [];
      final maxPage = (list.length / pageSize.value).ceil();
      final adjustedStart = (maxPage - 1) * pageSize.value;
      return list.sublist(adjustedStart);
    }
    final end = (start + pageSize.value).clamp(0, list.length);
    return list.sublist(start, end);
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
    try {
      await adminRepo.setRole(targetUid: uid, role: newRole);
      final idx = admins.indexWhere((a) => a.uid == uid);
      if (idx != -1) {
        admins[idx] = admins[idx].copyWith(role: newRole);
      }
      AppToast.success('Role Updated', 'Admin role updated to ${newRole.label}.');
      return true;
    } catch (e) {
      debugPrint('Error updating role: $e');
      AppToast.error('Failed to update role', e.toString());
      await loadAdmins();
      return false;
    }
  }

  Future<bool> toggleActive(String uid) async {
    if (uid == currentUid) {
      AppToast.error('Action Blocked', 'You cannot deactivate your own account.');
      return false;
    }

    final a = admins.firstWhereOrNull((x) => x.uid == uid);
    if (a == null) return false;
    final next = !a.active;
    try {
      await adminRepo.setActive(uid, next);
      final idx = admins.indexWhere((x) => x.uid == uid);
      if (idx != -1) {
        admins[idx] = admins[idx].copyWith(active: next);
      }
      AppToast.success(
        next ? 'Account Enabled' : 'Account Disabled',
        'Administrator account has been ${next ? 'enabled' : 'disabled'}.',
      );
      return true;
    } catch (e) {
      debugPrint('Error toggling active state: $e');
      AppToast.error('Failed to change status', e.toString());
      await loadAdmins();
      return false;
    }
  }
}
