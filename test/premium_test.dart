import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/premium_repository.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';
import 'package:joba_admin/features/premium/models/premium.dart';
import 'package:joba_admin/features/premium/views/premium_screen.dart';
import 'package:joba_admin/features/premium/views/widgets/premium_tab_bar.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<UserRepository>(MockUserRepository());
    Get.put<PremiumRepository>(MockPremiumRepository());

    final authService = AuthService();
    authService.user.value = const AdminUser(
      uid: 'adm-001',
      name: 'Super Admin',
      email: 'admin@joba.com',
      role: AdminRole.superAdmin,
    );
    Get.put(authService);
  });

  tearDown(Get.reset);

  group('Premium Models Serialization Tests', () {
    test('PromoCode round-trip toMap and fromMap', () {
      final now = DateTime(2026, 9, 1);
      final promo = PromoCode(
        code: 'EID2026',
        percentOff: 25,
        expiresAt: now,
        active: true,
        usedCount: 42,
      );

      final map = promo.toMap();
      final fromMap = PromoCode.fromMap(map, docId: 'EID2026');

      expect(fromMap.code, 'EID2026');
      expect(fromMap.percentOff, 25);
      expect(fromMap.active, isTrue);
      expect(fromMap.usedCount, 42);
    });

    test('Transaction round-trip toMap and fromMap', () {
      final now = DateTime(2026, 9, 1);
      final tx = Transaction(
        id: 'tx_123',
        userName: 'Sadia Islam',
        amountBdt: 499,
        method: 'bKash',
        date: now,
        status: TxStatus.success,
      );

      final map = tx.toMap();
      final fromMap = Transaction.fromMap(map, docId: 'tx_123');

      expect(fromMap.id, 'tx_123');
      expect(fromMap.userName, 'Sadia Islam');
      expect(fromMap.amountBdt, 499);
      expect(fromMap.method, 'bKash');
      expect(fromMap.status, TxStatus.success);
    });
  });

  group('PremiumRepository Tests', () {
    test('MockPremiumRepository handles CRUD operations on promos', () async {
      final repo = MockPremiumRepository();

      final initial = await repo.fetchPromos();
      expect(initial.length, 2);

      await repo.createPromo(
        PromoCode(
          code: 'NEW50',
          percentOff: 50,
          expiresAt: DateTime.now().add(const Duration(days: 10)),
        ),
      );

      final afterAdd = await repo.fetchPromos();
      expect(afterAdd.length, 3);
      expect(afterAdd.first.code, 'NEW50');

      await repo.togglePromo('NEW50', false);
      final afterToggle = await repo.fetchPromos();
      expect(afterToggle.first.active, isFalse);

      await repo.deletePromo('NEW50');
      final afterDelete = await repo.fetchPromos();
      expect(afterDelete.length, 2);
    });
  });

  group('PremiumController Tests', () {
    test('loads data and calculates stats correctly', () async {
      final controller = Get.put(PremiumController());
      await controller.loadData();

      expect(controller.premiumUsersCount, 2);
      expect(controller.activePromosCount, 2);
      expect(controller.transactionsCount, 2);
      expect(controller.monthlyRevenue, 499 + 2499);
    });

    test('filters and paginates promos', () async {
      final controller = Get.put(PremiumController());
      await controller.loadData();

      controller.searchController.text = 'SUMMER';
      expect(controller.filteredPromos.length, 1);
      expect(controller.filteredPromos.first.code, 'SUMMER20');

      controller.searchController.clear();
      expect(controller.paginatedPromos.length, 2);
    });

    test('adds promo and updates list', () async {
      final controller = Get.put(PremiumController());
      await controller.loadData();

      final success = await controller.addPromo(
        PromoCode(
          code: 'SPECIAL15',
          percentOff: 15,
          expiresAt: DateTime.now().add(const Duration(days: 15)),
        ),
      );

      expect(success, isTrue);
      expect(controller.promos.any((p) => p.code == 'SPECIAL15'), isTrue);
    });
  });

  group('PremiumScreen Widget Tests', () {
    Future<void> pumpPremium(
      WidgetTester tester, {
      Size size = const Size(1440, 900),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Get.put(PremiumController());
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: PremiumScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders header, stats grid, tab bar and default users tab', (
      tester,
    ) async {
      await pumpPremium(tester);

      expect(find.text('Premium & Payments'), findsOneWidget);
      expect(find.text('Premium Users'), findsWidgets);
      expect(find.text('Active Promos'), findsWidgets);
      expect(find.text('Transactions'), findsWidgets);
    });

    testWidgets('switches tabs between Users, Promos, and Transactions', (
      tester,
    ) async {
      await pumpPremium(tester);

      // Tap Promo Codes tab
      final promoTab = find.descendant(
        of: find.byType(PremiumTabBar),
        matching: find.text('Promo Codes'),
      );
      await tester.tap(promoTab);
      await tester.pumpAndSettle();

      expect(find.text('WELCOME10'), findsOneWidget);
      expect(find.text('SUMMER20'), findsOneWidget);

      // Tap Transactions tab
      final txTab = find.descendant(
        of: find.byType(PremiumTabBar),
        matching: find.text('Transactions'),
      );
      await tester.tap(txTab);
      await tester.pumpAndSettle();

      expect(find.text('tx_001'), findsOneWidget);
      expect(find.text('৳499'), findsOneWidget);
    });

    for (final size in const [
      Size(390, 844),
      Size(834, 1112),
      Size(1440, 900),
    ]) {
      testWidgets('renders without overflow at ${size.width.toInt()}x'
          '${size.height.toInt()}', (tester) async {
        await pumpPremium(tester, size: size);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
