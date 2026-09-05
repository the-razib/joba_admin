import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';

class UsersController extends GetxController {
  final UserRepository repo = Get.find();

  final loading = true.obs;
  final all = <AppUser>[].obs;

  final searchController = TextEditingController();
  final searchTick = 0.obs;
  final statusFilter = 'All Status'.obs;
  final planFilter = 'All Plans'.obs;
  final countryFilter = 'All Countries'.obs;
  final sortAsc = false.obs;
  final page = 1.obs;
  final pageSize = 10.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchTick.value++;
      page.value = 1;
    });
    loadUsers();
  }

  Future<void> loadUsers() async {
    loading.value = true;
    AppLoggerHelper.info('[UsersController] 👥 Fetching registered users...');
    try {
      final list = await repo.fetchUsers();
      all.assignAll(list);
      AppLoggerHelper.success('UsersController', 'Loaded ${list.length} users');
    } catch (e, st) {
      AppLoggerHelper.failure('UsersController', 'Could not load users: $e', error: e, stackTrace: st);
      AppToast.error('Load Failed', 'Could not load users: $e');
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<AppUser> get filtered {
    searchTick.value;
    var list = all.toList();
    final q = searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (u) =>
                u.name.toLowerCase().contains(q) ||
                u.email.toLowerCase().contains(q) ||
                u.uid.toLowerCase().contains(q),
          )
          .toList();
    }
    if (statusFilter.value != 'All Status') {
      list = list
          .where(
            (u) =>
                u.status.name.toLowerCase() == statusFilter.value.toLowerCase(),
          )
          .toList();
    }
    if (planFilter.value != 'All Plans') {
      list = list
          .where(
            (u) => u.plan.name.toLowerCase() == planFilter.value.toLowerCase(),
          )
          .toList();
    }
    if (countryFilter.value != 'All Countries') {
      list = list.where((u) => u.country == countryFilter.value).toList();
    }
    list.sort(
      (a, b) => sortAsc.value
          ? a.joinedAt.compareTo(b.joinedAt)
          : b.joinedAt.compareTo(a.joinedAt),
    );
    return list;
  }

  List<AppUser> get paged {
    final list = filtered;
    final start = (page.value - 1) * pageSize.value;
    if (start >= list.length) return [];
    final end = (start + pageSize.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalPages =>
      (filtered.length / pageSize.value).ceil().clamp(1, 99999);

  List<String> get countries =>
      all.map((u) => u.country).where((c) => c.isNotEmpty).toSet().toList()
        ..sort();

  void clearFilters() {
    searchController.clear();
    statusFilter.value = 'All Status';
    planFilter.value = 'All Plans';
    countryFilter.value = 'All Countries';
    page.value = 1;
  }

  void toggleSort() => sortAsc.value = !sortAsc.value;

  Future<void> updateStatus(String uid, UserStatus status) async {
    final i = all.indexWhere((u) => u.uid == uid);
    if (i >= 0) {
      final old = all[i];
      all[i] = old.copyWith(status: status);
      AppLoggerHelper.info('[UsersController] 🔄 Updating user $uid status to ${status.label}');
      try {
        await repo.updateUserStatus(uid, status);
        AppLoggerHelper.success('UsersController', 'User $uid marked as ${status.label}');
        AppToast.success('Status Updated', 'User marked as ${status.label}.');
      } catch (e, st) {
        all[i] = old;
        AppLoggerHelper.failure('UsersController', 'Could not update status: $e', error: e, stackTrace: st);
        AppToast.error('Update Failed', 'Could not update status: $e');
      }
    }
  }

  Future<void> updatePlan(String uid, UserPlan plan) async {
    final i = all.indexWhere((u) => u.uid == uid);
    if (i >= 0) {
      final old = all[i];
      all[i] = old.copyWith(plan: plan);
      AppLoggerHelper.info('[UsersController] 💳 Updating user $uid plan to ${plan.label}');
      try {
        await repo.updateUserPlan(uid, plan);
        AppLoggerHelper.success('UsersController', 'User $uid plan updated to ${plan.label}');
        AppToast.success(
          'Plan Updated',
          'User upgraded/downgraded to ${plan.label}.',
        );
      } catch (e, st) {
        all[i] = old;
        AppLoggerHelper.failure('UsersController', 'Could not update plan: $e', error: e, stackTrace: st);
        AppToast.error('Update Failed', 'Could not update plan: $e');
      }
    }
  }

  Future<void> remove(String uid) async {
    final i = all.indexWhere((u) => u.uid == uid);
    if (i >= 0) {
      final removed = all.removeAt(i);
      AppLoggerHelper.info('[UsersController] 🗑️ Deleting user $uid...');
      try {
        await repo.deleteUser(uid);
        AppLoggerHelper.success('UsersController', 'User $uid removed successfully');
        AppToast.success('User Deleted', 'User removed successfully.');
      } catch (e, st) {
        all.insert(i, removed);
        AppLoggerHelper.failure('UsersController', 'Could not delete user: $e', error: e, stackTrace: st);
        AppToast.error('Delete Failed', 'Could not delete user: $e');
      }
    }
  }
}
