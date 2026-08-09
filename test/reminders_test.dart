import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/reminder_template.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';
import 'package:joba_admin/features/reminders/views/reminders_screen.dart';

void main() {
  late RemindersController controller;

  setUp(() async {
    Get.put<UserRepository>(MockUserRepository());
    controller = Get.put(RemindersController());
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(Get.reset);

  test('seeds users and starts on the default order with no pending edits', () {
    expect(controller.loading.value, isFalse);
    expect(controller.users, isNotEmpty);
    expect(controller.order, [
      ReminderKind.pad,
      ReminderKind.periodPrep,
      ReminderKind.medicine,
    ]);
    expect(controller.isDirty, isFalse);
  });

  test('move applies ReorderableListView insertion-slot semantics', () {
    controller.move(0, 3); // drag first item past the last slot
    expect(controller.order, [
      ReminderKind.periodPrep,
      ReminderKind.medicine,
      ReminderKind.pad,
    ]);

    controller.move(2, 0); // drag it back to the top
    expect(controller.order, [
      ReminderKind.pad,
      ReminderKind.periodPrep,
      ReminderKind.medicine,
    ]);
  });

  test('arrows swap neighbours and stay inside the list bounds', () {
    controller.moveDown(0);
    expect(controller.order.first, ReminderKind.periodPrep);
    expect(controller.order[1], ReminderKind.pad);

    controller.moveUp(1);
    expect(controller.order.first, ReminderKind.pad);

    final before = [...controller.order];
    controller.moveUp(0);
    controller.moveDown(controller.order.length - 1);
    expect(controller.order, before);
  });

  test('reset restores the last saved order', () {
    controller.moveDown(0);
    expect(controller.isDirty, isTrue);
    expect(controller.order.first, ReminderKind.periodPrep);

    controller.resetOrder();
    expect(controller.isDirty, isFalse);
    expect(controller.order.first, ReminderKind.pad);
  });

  testWidgets('save publishes the draft as the new baseline', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    controller.moveDown(0);
    expect(controller.isDirty, isTrue);

    final saving = controller.saveOrder();
    expect(controller.saving.value, isTrue);
    await tester.pump(const Duration(milliseconds: 500));
    await saving;

    expect(controller.saving.value, isFalse);
    expect(controller.isDirty, isFalse);
    expect(controller.order.first, ReminderKind.periodPrep);

    // Reset now snaps back to the freshly saved order, not the default one.
    controller.moveDown(0);
    controller.resetOrder();
    expect(controller.order.first, ReminderKind.periodPrep);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  test('usage metrics are derived from the seeded users', () {
    final users = controller.users;
    expect(
      controller.trackerCount,
      users.where((u) => u.reminders.isNotEmpty).length,
    );
    expect(controller.notTrackingCount, users.length - controller.trackerCount);
    expect(
      controller.adoptionPercent,
      closeTo(controller.trackerCount / users.length * 100, 0.001),
    );
    expect(controller.avgPerTracker, greaterThan(1));

    for (final k in ReminderKind.values) {
      expect(
        controller.trackersOf(k),
        users.where((u) => u.reminders.contains(k)).length,
      );
    }
  });

  test('kindCounts follows the current home-screen order', () {
    controller.moveDown(0);
    expect(
      controller.kindCounts.map((e) => e.$1).toList(),
      controller.order.toList(),
    );
  });

  for (final (label, size) in const [
    ('mobile', Size(390, 844)),
    ('tablet', Size(834, 1112)),
    ('desktop', Size(1440, 900)),
  ]) {
    testWidgets('reminders screen lays out cleanly on $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: RemindersScreen())),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Reminder Tracker'), findsOneWidget);
      expect(find.text('Home Screen Order'), findsOneWidget);
      expect(find.text('Home Screen Preview'), findsOneWidget);
      expect(find.text('Reminder Usage'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the order tiles are draggable at every breakpoint', (
    tester,
  ) async {
    for (final size in const [Size(390, 844), Size(1440, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: RemindersScreen())),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is ReorderableDragStartListener ||
              w is ReorderableDelayedDragStartListener,
        ),
        findsNWidgets(controller.order.length),
        reason: 'each tile needs a drag listener at ${size.width}px',
      );
    }
    addTearDown(tester.view.reset);
  });
}
