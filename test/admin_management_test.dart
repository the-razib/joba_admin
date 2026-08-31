import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/admin_repository.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_management_controller.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/admin_management/views/admin_management_screen.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_management_table.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(ThemeService());
    final auth = Get.put(AuthService());
    auth.user.value = const AdminUser(
      uid: 'adm-001',
      name: 'Md. Razib Hasan',
      email: 'admin@joba.app',
      role: AdminRole.superAdmin,
    );
    Get.put<AdminRepository>(MockAdminRepository());
  });

  tearDown(() {
    Get.reset();
  });

  test('AdminManagementController loads initial admins from repository', () async {
    final controller = Get.put(AdminManagementController());
    await controller.loadAdmins();

    expect(controller.admins.length, greaterThanOrEqualTo(5));
    expect(controller.admins.first.name, 'Md. Razib Hasan');
    expect(controller.admins.first.role, AdminRole.superAdmin);
  });

  test('AdminManagementController invite creates admin with temp password', () async {
    final controller = Get.put(AdminManagementController());
    await controller.loadAdmins();

    final result = await controller.invite(
      name: 'New Officer',
      email: 'officer@joba.app',
      role: AdminRole.editor,
    );

    expect(result, isNotNull);
    expect(result!.email, 'officer@joba.app');
    expect(result.role, AdminRole.editor);
    expect(result.tempPassword, isNotEmpty);
    expect(controller.admins.any((a) => a.email == 'officer@joba.app'), isTrue);
  });

  test('AdminManagementController setRole updates role', () async {
    final controller = Get.put(AdminManagementController());
    await controller.loadAdmins();

    final success = await controller.setRole('adm-003', AdminRole.editor);
    expect(success, isTrue);
    final target = controller.admins.firstWhere((a) => a.uid == 'adm-003');
    expect(target.role, AdminRole.editor);
  });

  test('AdminManagementController blocks self-deactivation', () async {
    final controller = Get.put(AdminManagementController());
    await controller.loadAdmins();

    final success = await controller.toggleActive('adm-001');
    expect(success, isFalse);
    final self = controller.admins.firstWhere((a) => a.uid == 'adm-001');
    expect(self.active, isTrue);
  });

  test('AdminManagementController toggles active for other admins', () async {
    final controller = Get.put(AdminManagementController());
    await controller.loadAdmins();

    final success = await controller.toggleActive('adm-002');
    expect(success, isTrue);
    final target = controller.admins.firstWhere((a) => a.uid == 'adm-002');
    expect(target.active, isFalse);
  });

  testWidgets('AdminManagementScreen renders table and invite button', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Get.put(AdminManagementController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: AdminManagementScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Admin Management'), findsOneWidget);
    expect(find.text('Add Admin'), findsOneWidget);
    expect(find.byType(AdminManagementTable), findsOneWidget);
    expect(find.text('Md. Razib Hasan'), findsOneWidget);
    expect(find.text('Farha Islam'), findsOneWidget);
  });
}
