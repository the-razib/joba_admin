import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/notifications/controllers/admin_notifications_controller.dart';
import 'package:joba_admin/features/notifications/models/admin_notification_item.dart';
import 'package:joba_admin/features/notifications/views/widgets/admin_notifications_popover.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';
import 'package:joba_admin/features/shell/widgets/top_bar.dart';

void main() {
  group('AdminNotificationsController Tests', () {
    late AdminNotificationsController controller;

    setUp(() async {
      Get.testMode = true;
      Get.put(ThemeService());
      controller = Get.put(AdminNotificationsController());
      await controller.loadNotifications();
    });

    tearDown(() {
      Get.reset();
    });

    test('Initializes with fallback seed data when Firestore is offline', () {
      expect(controller.isLoading.value, isFalse);
      expect(controller.notifications, isNotEmpty);
      expect(controller.unreadCount, greaterThan(0));
    });

    test('Filters notifications by category correctly', () {
      // Default: All
      expect(controller.activeFilter.value, NotificationCategory.all);
      expect(
        controller.filteredNotifications.length,
        controller.notifications.length,
      );

      // Reports & Feedback filter
      controller.setFilter(NotificationCategory.report);
      expect(controller.activeFilter.value, NotificationCategory.report);
      expect(
        controller.filteredNotifications.every(
          (n) => n.category == NotificationCategory.report,
        ),
        isTrue,
      );

      // Security filter
      controller.setFilter(NotificationCategory.security);
      expect(controller.activeFilter.value, NotificationCategory.security);
      expect(
        controller.filteredNotifications.every(
          (n) => n.category == NotificationCategory.security,
        ),
        isTrue,
      );
    });

    test('markAsRead updates unread count and marks item read', () {
      final unreadItems =
          controller.notifications.where((n) => !n.isRead).toList();
      expect(unreadItems, isNotEmpty);

      final initialUnread = controller.unreadCount;
      final target = unreadItems.first;

      controller.markAsRead(target.id);

      expect(controller.unreadCount, initialUnread - 1);
      expect(controller.readIds.contains(target.id), isTrue);
    });

    test('markAllAsRead marks all notifications as read', () {
      expect(controller.unreadCount, greaterThan(0));

      controller.markAllAsRead();

      expect(controller.unreadCount, 0);
    });
  });

  group('AdminNotificationsPopover & TopBar Widget Tests', () {
    late AdminNotificationsController controller;

    setUp(() async {
      Get.testMode = true;
      Get.put(ThemeService());
      Get.put(ShellController());
      final auth = Get.put(AuthService());
      auth.user.value = const AdminUser(
        uid: 'adm-001',
        name: 'Razib Admin',
        email: 'admin@joba.app',
        role: AdminRole.superAdmin,
      );
      controller = Get.put(AdminNotificationsController());
      await controller.loadNotifications();
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('AdminNotificationsPopover renders header, filters, and items', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  maxHeight: 520,
                ),
                child: const AdminNotificationsPopover(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header elements
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark read'), findsOneWidget);

      // Category filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Reports & Feedback'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);

      // Tap on Mark read
      await tester.tap(find.text('Mark read'));
      await tester.pumpAndSettle();
      expect(controller.unreadCount, 0);
    });

    testWidgets('TopBar renders dynamic notification badge matching controller unreadCount', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            appBar: const TopBar(),
            body: Container(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // TopBar has notifications bell icon
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      // Unread count text should be rendered in badge
      final count = controller.unreadCount;
      expect(find.text('$count'), findsOneWidget);

      // Marking all read removes the badge count text
      controller.markAllAsRead();
      await tester.pumpAndSettle();
      expect(find.text('$count'), findsNothing);
    });
  });
}
