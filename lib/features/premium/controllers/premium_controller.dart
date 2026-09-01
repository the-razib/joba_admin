import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/premium_repository.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/premium/models/premium.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

class PremiumController extends GetxController {
  final PremiumRepository repo = Get.find<PremiumRepository>();

  final loading = true.obs;
  final users = <AppUser>[].obs;
  final promos = <PromoCode>[].obs;
  final transactions = <Transaction>[].obs;
  final tab = 0.obs; // 0 users, 1 promos, 2 transactions

  final searchController = TextEditingController();
  final searchTick = 0.obs;
  final page = 1.obs;
  final pageSize = 10.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchTick.value++;
      page.value = 1;
    });
    ever(tab, (_) {
      page.value = 1;
      searchController.clear();
    });
    loadData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    loading.value = true;
    try {
      final results = await Future.wait([
        repo.fetchPremiumUsers(),
        repo.fetchPromos(),
        repo.fetchTransactions(),
      ]);
      users.assignAll(results[0] as List<AppUser>);
      promos.assignAll(results[1] as List<PromoCode>);
      transactions.assignAll(results[2] as List<Transaction>);
    } catch (e) {
      debugPrint('Error loading premium data: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshData() => loadData();

  int get monthlyRevenue => transactions
      .where((t) => t.status == TxStatus.success)
      .fold<int>(0, (a, t) => a + t.amountBdt);

  int get activePromosCount => promos.where((p) => p.active).length;

  int get transactionsCount => transactions.length;

  int get premiumUsersCount => users.length;

  List<AppUser> get filteredUsers {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  List<AppUser> get paginatedUsers {
    final list = filteredUsers;
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

  List<PromoCode> get filteredPromos {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return promos;
    return promos.where((p) => p.code.toLowerCase().contains(q)).toList();
  }

  List<PromoCode> get paginatedPromos {
    final list = filteredPromos;
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

  List<Transaction> get filteredTransactions {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return transactions;
    return transactions
        .where((t) =>
            t.userName.toLowerCase().contains(q) ||
            t.id.toLowerCase().contains(q) ||
            t.method.toLowerCase().contains(q))
        .toList();
  }

  List<Transaction> get paginatedTransactions {
    final list = filteredTransactions;
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

  Future<void> togglePromo(String code) async {
    final idx = promos.indexWhere((p) => p.code == code);
    if (idx >= 0) {
      final newStatus = !promos[idx].active;
      promos[idx] = promos[idx].copyWith(active: newStatus);
      try {
        await repo.togglePromo(code, newStatus);
        AppToast.success(
          newStatus ? 'Promo Activated' : 'Promo Deactivated',
          'Promo code $code has been ${newStatus ? 'activated' : 'deactivated'}.',
        );
      } catch (e) {
        promos[idx] = promos[idx].copyWith(active: !newStatus);
        AppToast.error('Failed to update promo', e.toString());
      }
    }
  }

  Future<bool> addPromo(PromoCode p) async {
    try {
      await repo.createPromo(p);
      promos.insert(0, p);
      AppToast.success('Promo Created', 'Promo code ${p.code} created successfully.');
      return true;
    } catch (e) {
      AppToast.error('Create Failed', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> deletePromo(String code) async {
    final idx = promos.indexWhere((p) => p.code == code);
    if (idx >= 0) {
      final removed = promos.removeAt(idx);
      try {
        await repo.deletePromo(code);
        AppToast.success('Promo Deleted', 'Promo code $code deleted.');
      } catch (e) {
        promos.insert(idx, removed);
        AppToast.error('Delete Failed', e.toString());
      }
    }
  }
}
