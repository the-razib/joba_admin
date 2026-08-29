import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

void main() {
  group('UsersController', () {
    late UsersController controller;
    late MockUserRepository mockRepo;

    setUp(() async {
      Get.testMode = true;
      mockRepo = MockUserRepository();
      Get.put<UserRepository>(mockRepo);
      controller = UsersController();
      Get.put(controller);
      await controller.loadUsers();
    });

    tearDown(() {
      Get.reset();
    });

    test('loads all users successfully', () {
      expect(controller.all.isNotEmpty, isTrue);
      expect(controller.all.length, 12);
      expect(controller.loading.value, isFalse);
    });

    test('filters users by search query', () {
      controller.searchController.text = 'Farhana';
      controller.searchTick.value++;
      expect(controller.filtered.length, 1);
      expect(controller.filtered.first.name, 'Farhana Akter');

      controller.searchController.text = '';
      controller.searchTick.value++;
      expect(controller.filtered.length, 12);
    });

    test('filters users by status', () {
      controller.statusFilter.value = 'Blocked';
      expect(controller.filtered.length, 1);
      expect(controller.filtered.first.status, UserStatus.blocked);

      controller.statusFilter.value = 'Active';
      expect(
        controller.filtered.every((u) => u.status == UserStatus.active),
        isTrue,
      );
    });

    test('filters users by plan', () {
      controller.planFilter.value = 'Premium';
      expect(
        controller.filtered.every((u) => u.plan == UserPlan.premium),
        isTrue,
      );
    });

    test('filters users by country', () {
      controller.countryFilter.value = 'India';
      expect(
        controller.filtered.every((u) => u.country == 'India'),
        isTrue,
      );
    });

    test('updates user status and plan', () async {
      final user = controller.all.first;
      await controller.updateStatus(user.uid, UserStatus.blocked);
      expect(controller.all.first.status, UserStatus.blocked);

      await controller.updatePlan(user.uid, UserPlan.premium);
      expect(controller.all.first.plan, UserPlan.premium);
    });

    test('deletes a user', () async {
      final initialCount = controller.all.length;
      final uidToDelete = controller.all.first.uid;

      await controller.remove(uidToDelete);
      expect(controller.all.length, initialCount - 1);
      expect(controller.all.any((u) => u.uid == uidToDelete), isFalse);
    });
  });
}
