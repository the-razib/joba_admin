import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_profile_controller.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_profile_dialog.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(ThemeService());
    final auth = Get.put(AuthService());
    auth.user.value = const AdminUser(
      uid: 'adm-001',
      name: 'Super Administrator',
      email: 'admin@joba.app',
      role: AdminRole.superAdmin,
      photoUrl: 'https://example.com/photo.jpg',
    );
  });

  tearDown(() {
    Get.reset();
  });

  test('AdminUser copyWith correctly updates name, photo and clearPhoto flag', () {
    const original = AdminUser(
      uid: 'adm-test',
      name: 'Original Name',
      email: 'test@joba.app',
      role: AdminRole.editor,
      photoUrl: 'https://example.com/pic.jpg',
    );

    final renamed = original.copyWith(name: 'Updated Name');
    expect(renamed.name, 'Updated Name');
    expect(renamed.photoUrl, 'https://example.com/pic.jpg');

    final cleared = original.copyWith(clearPhoto: true);
    expect(cleared.photoUrl, isNull);
    expect(cleared.name, 'Original Name');

    final newPhoto = original.copyWith(photoUrl: 'https://example.com/new.jpg');
    expect(newPhoto.photoUrl, 'https://example.com/new.jpg');
  });

  test('AdminProfileController initializes with current admin name and controllers', () {
    final controller = Get.put(AdminProfileController());
    expect(controller.nameController.text, 'Super Administrator');
    expect(controller.obscureCurrent.value, isTrue);
    expect(controller.obscureNew.value, isTrue);
    expect(controller.obscureConfirm.value, isTrue);
    expect(controller.user?.email, 'admin@joba.app');
  });

  testWidgets('AdminProfileDialog renders header, user details and tabs', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: AdminProfileDialog(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verifies user details in the dialog header
    expect(find.text('Super Administrator'), findsAtLeastNWidgets(1));
    expect(find.text('admin@joba.app'), findsAtLeastNWidgets(1));
    expect(find.text('Super Admin'), findsAtLeastNWidgets(1));

    // Verifies the 3 tabs
    expect(find.text('Profile Info'), findsOneWidget);
    expect(find.text('Security & Password'), findsOneWidget);
    expect(find.text('Role & Privileges'), findsOneWidget);

    // Verifies Account Information elements
    expect(find.text('Display Name'), findsOneWidget);
    expect(find.text('Account Information'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Verified Login'), findsOneWidget);
    expect(find.text('Active Admin'), findsOneWidget);
  });

  testWidgets('AdminProfileDialog switches tabs to Security and Role Privileges', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: AdminProfileDialog(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Security & Password tab
    await tester.tap(find.text('Security & Password'));
    await tester.pumpAndSettle();

    expect(find.text('Current Password'), findsOneWidget);
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm New Password'), findsOneWidget);
    expect(find.text('Update Password'), findsOneWidget);

    // Tap Role & Privileges tab
    await tester.tap(find.text('Role & Privileges'));
    await tester.pumpAndSettle();

    expect(find.text('Assigned Role:'), findsOneWidget);
    expect(find.text('Manage Content & Articles'), findsOneWidget);
    expect(find.text('Push Notification Broadcasts'), findsOneWidget);
    expect(find.text('Administrator Management'), findsOneWidget);
    expect(find.text('Audit Logs & Security Trail'), findsOneWidget);
  });
}
