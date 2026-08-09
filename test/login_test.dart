import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
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

    await tester.pumpWidget(const GetMaterialApp(home: LoginScreen()));
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
      expect(
        find.byType(ActionChip),
        findsNWidgets(AuthService.demoAccounts.length),
      );
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

  testWidgets('a demo chip fills in that role\'s credentials', (tester) async {
    await pumpLogin(tester, const Size(1440, 900));
    final controller = Get.find<AuthController>();
    final (email, password, role) = AuthService.demoAccounts.last;

    await tester.tap(find.widgetWithText(ActionChip, role));
    await tester.pump();

    expect(controller.emailController.text, email);
    expect(controller.passwordController.text, password);
  });
}
