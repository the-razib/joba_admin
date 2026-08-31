import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/config_repository.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';

void main() {
  group('RemindersController', () {
    late RemindersController controller;
    late MockUserRepository mockUserRepo;
    late MockConfigRepository mockConfigRepo;

    setUp(() async {
      Get.testMode = true;
      mockUserRepo = MockUserRepository();
      mockConfigRepo = MockConfigRepository();

      Get.put<UserRepository>(mockUserRepo);
      Get.put<ConfigRepository>(mockConfigRepo);

      controller = RemindersController();
      Get.put(controller);
      await controller.refreshData();
    });

    tearDown(() {
      Get.reset();
    });

    test('loads initial reminder order and users successfully', () {
      expect(controller.loading.value, isFalse);
      expect(controller.order.length, 3);
      expect(controller.order[0], ReminderKind.pad);
      expect(controller.order[1], ReminderKind.periodPrep);
      expect(controller.order[2], ReminderKind.medicine);
      expect(controller.isDirty, isFalse);
    });

    test('reorders reminders with move and detects isDirty state', () {
      controller.move(0, 2);
      expect(controller.isDirty, isTrue);
      expect(controller.order[0], ReminderKind.periodPrep);
      expect(controller.order[1], ReminderKind.pad);
      expect(controller.order[2], ReminderKind.medicine);

      controller.resetOrder();
      expect(controller.isDirty, isFalse);
      expect(controller.order[0], ReminderKind.pad);
    });

    test('moveUp and moveDown swap correctly', () {
      controller.moveDown(0);
      expect(controller.order[0], ReminderKind.periodPrep);
      expect(controller.order[1], ReminderKind.pad);

      controller.moveUp(1);
      expect(controller.order[0], ReminderKind.pad);
      expect(controller.order[1], ReminderKind.periodPrep);
    });

    test('saves new order to ConfigRepository and resets isDirty', () async {
      controller.move(2, 0); // Move medicine to first position
      expect(controller.isDirty, isTrue);

      await controller.saveOrder();
      expect(controller.isDirty, isFalse);

      final savedDoc = await mockConfigRepo.getDoc('reminders');
      expect(savedDoc, isNotNull);
      expect(savedDoc!['order'], ['medicine', 'pad', 'periodPrep']);
    });

    test('computes adoption metrics across user base', () {
      expect(controller.trackerCount, greaterThanOrEqualTo(0));
      expect(controller.notTrackingCount, greaterThanOrEqualTo(0));
      expect(controller.adoptionPercent, greaterThanOrEqualTo(0));
      expect(controller.adoptionPercent, lessThanOrEqualTo(100));
      expect(controller.kindCounts.length, 3);
    });
  });
}
