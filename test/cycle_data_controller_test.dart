import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/features/cycle_data/controllers/cycle_data_controller.dart';

void main() {
  group('CycleDataController', () {
    late CycleDataController controller;
    late MockUserRepository mockRepo;

    setUp(() async {
      Get.testMode = true;
      mockRepo = MockUserRepository();
      Get.put<UserRepository>(mockRepo);
      controller = CycleDataController();
      Get.put(controller);
      await controller.refreshData();
    });

    tearDown(() {
      Get.reset();
    });

    test('loads live users and populates sampleSize', () {
      expect(controller.loading.value, isFalse);
      expect(controller.users.isNotEmpty, isTrue);
      expect(controller.sampleSize, 12);
    });

    test('calculates correct averages for cycle and period duration', () {
      expect(controller.avgCycle, greaterThan(20.0));
      expect(controller.avgCycle, lessThan(35.0));
      expect(controller.avgPeriod, greaterThan(3.0));
      expect(controller.avgPeriod, lessThan(8.0));
    });

    test('partitions cycle length buckets properly', () {
      final buckets = controller.lengthBuckets;
      expect(buckets.length, 4);
      final totalBucketed = buckets.map((b) => b.$2).reduce((a, b) => a + b);
      expect(totalBucketed, controller.sampleSize);
    });

    test('partitions age demographic buckets properly', () {
      final ageBuckets = controller.ageBuckets;
      expect(ageBuckets.length, 5);
      final totalAgeCount =
          ageBuckets.map((b) => b.$2).reduce((a, b) => a + b);
      expect(totalAgeCount, lessThanOrEqualTo(controller.sampleSize));
    });

    test('computes goal counts for tracking, conception, and avoidance', () {
      final goals = controller.goalCounts;
      expect(goals.containsKey('track'), isTrue);
      expect(goals.containsKey('conceive'), isTrue);
      expect(goals.containsKey('avoid'), isTrue);
      final sum = (goals['track'] ?? 0) +
          (goals['conceive'] ?? 0) +
          (goals['avoid'] ?? 0);
      expect(sum, controller.sampleSize);
    });

    test('filters lookup list by search text query', () {
      controller.searchController.text = 'Farhana';
      controller.searchTick.value++;
      expect(controller.lookup.length, 1);
      expect(controller.lookup.first.name, 'Farhana Akter');

      controller.searchController.text = 'non-existent-user';
      controller.searchTick.value++;
      expect(controller.lookup.isEmpty, isTrue);

      controller.searchController.text = '';
      controller.searchTick.value++;
      expect(controller.lookup.length, 12);
    });

    test('handles empty user list gracefully without division by zero', () {
      controller.users.clear();
      expect(controller.sampleSize, 0);
      expect(controller.avgCycle, 0.0);
      expect(controller.avgPeriod, 0.0);
      expect(controller.lookup.isEmpty, isTrue);
    });
  });
}
