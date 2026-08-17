import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';

class UsersController extends GetxController {
  final UserRepository repo = Get.find();

  final loading = true.obs;
  final all = <AppUser>[].obs;

  final searchController = TextEditingController();
  final statusFilter = 'All Status'.obs;
  final planFilter = 'All Plans'.obs;
  final countryFilter = 'All Countries'.obs;
  final sortAsc = false.obs;
  final page = 1.obs;
  final pageSize = 10.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => page.value = 1);
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    all.assignAll(await repo.seedUsers());
    loading.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<AppUser> get filtered {
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
      all.map((u) => u.country).toSet().toList()..sort();

  void clearFilters() {
    searchController.clear();
    statusFilter.value = 'All Status';
    planFilter.value = 'All Plans';
    countryFilter.value = 'All Countries';
    page.value = 1;
  }

  void toggleSort() => sortAsc.value = !sortAsc.value;

  void updateStatus(String uid, UserStatus status) {
    final i = all.indexWhere((u) => u.uid == uid);
    if (i >= 0) all[i] = all[i].copyWith(status: status);
  }

  void updatePlan(String uid, UserPlan plan) {
    final i = all.indexWhere((u) => u.uid == uid);
    if (i >= 0) all[i] = all[i].copyWith(plan: plan);
  }

  void remove(String uid) => all.removeWhere((u) => u.uid == uid);
}
