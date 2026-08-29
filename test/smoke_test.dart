import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/features/dashboard/views/widgets/country_distribution_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/user_activity_chart_card.dart';
import 'package:joba_admin/main.dart';
import 'package:joba_admin/routes/app_routes.dart';

void main() {
  testWidgets('login renders and signs into the dashboard shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Get.put(ThemeService());
    Get.put(AuthService());
    addTearDown(Get.reset);

    final auth = Get.find<AuthService>();
    await tester.pumpWidget(const JobaAdminApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Joba Admin'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);

    // Transition into dashboard shell with active authenticated user
    auth.user.value = const AdminUser(
      uid: 'adm-001',
      name: 'Md. Razib Hasan',
      email: 'admin@joba.app',
      role: AdminRole.superAdmin,
    );
    Get.offAllNamed(AppRoutes.shell);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('User Activity Overview'), findsOneWidget);
    expect(find.text('Users by Country'), findsOneWidget);

    final activityCardFinder = find.byType(UserActivityChartCard);
    final countryCardFinder = find.byType(CountryDistributionCard);
    expect(activityCardFinder, findsOneWidget);
    expect(countryCardFinder, findsOneWidget);
    final activitySize = tester.getSize(activityCardFinder);
    final countrySize = tester.getSize(countryCardFinder);
    expect(countrySize.height, equals(activitySize.height));
  });

  testWidgets('mobile layout shows bottom navigation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Get.put(ThemeService());
    Get.put(AuthService());
    Get.find<AuthService>().user.value = const AdminUser(
      uid: 'adm-001',
      name: 'Md. Razib Hasan',
      email: 'admin@joba.app',
      role: AdminRole.superAdmin,
    );
    addTearDown(Get.reset);

    await tester.pumpWidget(const JobaAdminApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('More'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('every phase 2 section renders on desktop', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Get.put(ThemeService());
    Get.put(AuthService());
    Get.find<AuthService>().user.value = const AdminUser(
      uid: 'adm-001',
      name: 'Md. Razib Hasan',
      email: 'admin@joba.app',
      role: AdminRole.superAdmin,
    );
    addTearDown(Get.reset);

    await tester.pumpWidget(const JobaAdminApp());
    await tester.pump(const Duration(milliseconds: 400));

    const sections = [
      'Users',
      'Cycle Data',
      'Articles',
      'Avatar Management',
      'Reminders',
      'Push Notifications',
      'Reports & Feedback',
      'Premium & Payments',
      'App Settings',
      'Admin Management',
      'Audit Logs',
    ];
    for (final label in sections) {
      await tester.tap(find.text(label).first);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        find.text(label),
        findsWidgets,
        reason: 'section "$label" should render',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'section "$label" must not throw',
      );
    }
  });
}
