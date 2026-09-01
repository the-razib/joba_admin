import 'package:joba_admin/features/premium/models/premium.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

abstract class PremiumRepository {
  Future<List<AppUser>> fetchPremiumUsers();
  Future<List<PromoCode>> fetchPromos();
  Future<void> createPromo(PromoCode promo);
  Future<void> togglePromo(String code, bool active);
  Future<void> deletePromo(String code);
  Future<List<Transaction>> fetchTransactions({int limit = 100});
}

class MockPremiumRepository implements PremiumRepository {
  final List<PromoCode> _promos = [
    PromoCode(
      code: 'WELCOME10',
      percentOff: 10,
      expiresAt: DateTime.now().add(const Duration(days: 90)),
      usedCount: 24,
      active: true,
    ),
    PromoCode(
      code: 'SUMMER20',
      percentOff: 20,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      usedCount: 15,
      active: true,
    ),
  ];

  final List<Transaction> _transactions = [
    Transaction(
      id: 'tx_001',
      userName: 'Nusrat Jahan',
      amountBdt: 499,
      method: 'bKash',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: TxStatus.success,
    ),
    Transaction(
      id: 'tx_002',
      userName: 'Tania Ahmed',
      amountBdt: 2499,
      method: 'Nagad',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: TxStatus.success,
    ),
  ];

  final List<AppUser> _premiumUsers = [
    AppUser(
      uid: 'user_prem_1',
      name: 'Nusrat Jahan',
      email: 'nusrat@example.com',
      photoUrl: '',
      status: UserStatus.active,
      plan: UserPlan.premium,
      country: 'Bangladesh',
      countryCode: 'BD',
      joinedAt: DateTime.now().subtract(const Duration(days: 45)),
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      language: 'bn',
      averageCycleLength: 28,
      averagePeriodDuration: 5,
      cycleGoal: 'Track Cycle',
    ),
    AppUser(
      uid: 'user_prem_2',
      name: 'Tania Ahmed',
      email: 'tania@example.com',
      photoUrl: '',
      status: UserStatus.active,
      plan: UserPlan.premium,
      country: 'Bangladesh',
      countryCode: 'BD',
      joinedAt: DateTime.now().subtract(const Duration(days: 80)),
      lastActive: DateTime.now().subtract(const Duration(hours: 5)),
      language: 'bn',
      averageCycleLength: 30,
      averagePeriodDuration: 6,
      cycleGoal: 'Track Cycle',
    ),
  ];

  @override
  Future<List<AppUser>> fetchPremiumUsers() async => List.unmodifiable(_premiumUsers);

  @override
  Future<List<PromoCode>> fetchPromos() async => List.unmodifiable(_promos);

  @override
  Future<void> createPromo(PromoCode promo) async {
    _promos.removeWhere((p) => p.code.toUpperCase() == promo.code.toUpperCase());
    _promos.insert(0, promo);
  }

  @override
  Future<void> togglePromo(String code, bool active) async {
    final idx = _promos.indexWhere((p) => p.code.toUpperCase() == code.toUpperCase());
    if (idx != -1) {
      _promos[idx] = _promos[idx].copyWith(active: active);
    }
  }

  @override
  Future<void> deletePromo(String code) async {
    _promos.removeWhere((p) => p.code.toUpperCase() == code.toUpperCase());
  }

  @override
  Future<List<Transaction>> fetchTransactions({int limit = 100}) async =>
      List.unmodifiable(_transactions);
}
