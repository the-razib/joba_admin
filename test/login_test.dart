import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/auth/auth_controller.dart';
import 'package:joba_admin/features/auth/login_screen.dart';

void main() {
  setUp(() {
    Get.put(AuthService());
    Get.put(AuthController());
  });

  tearDown(Get.reset);

  Future<void> pumpLogin(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(GetMaterialApp(
      theme: AppTheme.light(),
      home: const LoginScreen(),
    ));
    await tester.pump(const Duration(milliseconds: 200));
  }

  for (final (label, size) in const [
    ('mobile', Size(390, 844)),
    ('tablet', Size(834, 1112)),
    ('desktop', Size(1440, 900)),
  ]) {
    testWidgets('renders a single centered card with the logo on $label', (
      tester,
    ) async {
      await pumpLogin(tester, size);

      final logo = tester.widget<Image>(find.byType(Image));
      expect(
        (logo.image as AssetImage).assetName,
        'assets/icons/app_icon.png',
        reason: 'the brand lockup must use the registered app icon',
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Joba Admin'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
      expect(find.text('Authorized Personnel Only'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('password visibility can be toggled', (tester) async {
    await pumpLogin(tester, const Size(1440, 900));
    final controller = Get.find<AuthController>();

    expect(controller.obscure.value, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(controller.obscure.value, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('an invalid email blocks submission', (tester) async {
    await pumpLogin(tester, const Size(1440, 900));
    final controller = Get.find<AuthController>();
    controller.emailController.text = 'not-an-email';

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(controller.loading.value, isFalse);
  });

  testWidgets('a password under 6 characters blocks submission', (tester) async {
    await pumpLogin(tester, const Size(1440, 900));
    final controller = Get.find<AuthController>();
    controller.emailController.text = 'admin@joba.app';
    controller.passwordController.text = '123';

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Minimum 6 characters'), findsOneWidget);
    expect(controller.loading.value, isFalse);
  });

  group('AdminRole.fromString parsing tests', () {
    test('parses superAdmin variants correctly', () {
      expect(AdminRole.fromString('superAdmin'), AdminRole.superAdmin);
      expect(AdminRole.fromString('super_admin'), AdminRole.superAdmin);
      expect(AdminRole.fromString('super admin'), AdminRole.superAdmin);
      expect(AdminRole.fromString('SUPERADMIN'), AdminRole.superAdmin);
    });

    test('parses editor correctly', () {
      expect(AdminRole.fromString('editor'), AdminRole.editor);
      expect(AdminRole.fromString('EDITOR'), AdminRole.editor);
    });

    test('parses viewer or unknown/null to viewer fallback', () {
      expect(AdminRole.fromString('viewer'), AdminRole.viewer);
      expect(AdminRole.fromString(null), AdminRole.viewer);
      expect(AdminRole.fromString('unknown_role'), AdminRole.viewer);
    });
  });
}
