import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/core/widgets/app_logo.dart';
import 'package:joba_admin/main.dart';

void main() {
  Future<void> pumpShell(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
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
  }

  testWidgets('the brand logo renders in the full desktop sidebar', (
    tester,
  ) async {
    await pumpShell(tester, const Size(1440, 900));

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Joba'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the collapsed tablet rail shows the logo without overflowing', (
    tester,
  ) async {
    await pumpShell(tester, const Size(834, 1112));

    expect(find.byType(AppLogo), findsOneWidget);
    // The rail hides the wordmark but must still fit the 42px mark in 76px.
    expect(find.text('Joba'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the mobile drawer shows the brand logo', (tester) async {
    await pumpShell(tester, const Size(390, 844));

    // The drawer is built lazily, so nothing brand-related is on screen yet.
    expect(find.byType(AppLogo), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Joba'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the logo resolves to the registered app icon asset', (
    tester,
  ) async {
    await pumpShell(tester, const Size(1440, 900));

    final image = tester.widget<Image>(
      find.descendant(of: find.byType(AppLogo), matching: find.byType(Image)),
    );
    expect((image.image as AssetImage).assetName, 'assets/icons/app_icon.png');
  });
}
