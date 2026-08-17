import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/features/premium/models/premium.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';

class PremiumController extends GetxController {
  final UserRepository repo = Get.find();

  final loading = true.obs;
  final users = <AppUser>[].obs;
  final promos = <PromoCode>[].obs;
  final transactions = <Transaction>[].obs;
  final tab = 0.obs; // 0 users, 1 promos, 2 transactions

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    users.assignAll(
      (await repo.seedUsers())
          .where((u) => u.plan == UserPlan.premium)
          .toList(),
    );
    final now = DateTime.now();
    promos.assignAll([
      PromoCode(code: 'SUMMER2026', percentOff: 20, expiresAt: now.add(const Duration(days: 26)), usedCount: 143),
      PromoCode(code: 'WELCOME10', percentOff: 10, expiresAt: now.add(const Duration(days: 200)), usedCount: 892),
      PromoCode(code: 'EID2026', percentOff: 25, expiresAt: now.subtract(const Duration(days: 60)), active: false, usedCount: 356),
    ]);
    transactions.assignAll([
      Transaction(id: 'TX-1042', userName: 'Farhana Akter', amountBdt: 499, method: 'bKash', date: now.subtract(const Duration(days: 2))),
      Transaction(id: 'TX-1041', userName: 'Ayesha Rahman', amountBdt: 499, method: 'Nagad', date: now.subtract(const Duration(days: 3))),
      Transaction(id: 'TX-1039', userName: 'Tania Ahmed', amountBdt: 2499, method: 'Card', date: now.subtract(const Duration(days: 5))),
      Transaction(id: 'TX-1036', userName: 'Sadia Islam', amountBdt: 499, method: 'bKash', date: now.subtract(const Duration(days: 6)), status: TxStatus.refunded),
      Transaction(id: 'TX-1033', userName: 'Lima Khatun', amountBdt: 499, method: 'bKash', date: now.subtract(const Duration(days: 8)), status: TxStatus.pending),
    ]);
    loading.value = false;
  }

  int get monthlyRevenue =>
      transactions.fold<int>(0, (a, t) => a + t.amountBdt);

  void togglePromo(String code) {
    final i = promos.indexWhere((p) => p.code == code);
    if (i >= 0) promos[i] = promos[i].copyWith(active: !promos[i].active);
  }

  void addPromo(PromoCode p) => promos.insert(0, p);
}
