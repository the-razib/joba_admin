import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';
import 'package:joba_admin/features/avatars/views/avatars_screen.dart';

void main() {
  setUp(() {
    Get.put(ThemeService());
    Get.put(AuthService());
    Get.find<AuthService>().user.value = const AdminUser(
      uid: 'adm-001',
      name: 'Md. Razib Hasan',
      email: 'admin@joba.app',
      role: AdminRole.superAdmin,
    );
    Get.put<AvatarRepository>(MockAvatarRepository());
    Get.put(AvatarsController());
  });

  tearDown(Get.reset);

  testWidgets(
    'avatar category chips immediately update selection state on tap',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: AvatarsScreen())),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify initial category is selected ('modern')
      final modernFinder = find.byKey(const ValueKey('modern'));
      final animalFinder = find.byKey(const ValueKey('animal'));

      expect(modernFinder, findsOneWidget);
      expect(animalFinder, findsOneWidget);

      final modernChipBefore = tester.widget<FilterChip>(modernFinder);
      expect(modernChipBefore.selected, isTrue);

      final animalChipBefore = tester.widget<FilterChip>(animalFinder);
      expect(animalChipBefore.selected, isFalse);

      // Tap the 'Animal' category chip
      await tester.tap(animalFinder);
      await tester.pumpAndSettle();

      // The selection should have changed immediately without needing a reload
      final modernChipAfter = tester.widget<FilterChip>(modernFinder);
      expect(modernChipAfter.selected, isFalse);

      final animalChipAfter = tester.widget<FilterChip>(animalFinder);
      expect(animalChipAfter.selected, isTrue);
    },
  );
}
