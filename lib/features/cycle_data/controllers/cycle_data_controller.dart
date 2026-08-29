import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';

class CycleDataController extends GetxController {
  final UserRepository repo = Get.find();

  final loading = true.obs;
  final users = <AppUser>[].obs;
  final searchController = TextEditingController();
  final searchTick = 0.obs;

  int get sampleSize => users.length;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    try {
      final list = await repo.fetchUsers();
      users.assignAll(list);
    } catch (e) {
      debugPrint('Error loading cycle users: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _load();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  double get avgCycle => users.isEmpty
      ? 0
      : users.map((u) => u.averageCycleLength).reduce((a, b) => a + b) /
          users.length;

  double get avgPeriod => users.isEmpty
      ? 0
      : users.map((u) => u.averagePeriodDuration).reduce((a, b) => a + b) /
          users.length;

  Map<String, int> get goalCounts {
    final m = {'track': 0, 'conceive': 0, 'avoid': 0};
    for (final u in users) {
      m[u.cycleGoal] = (m[u.cycleGoal] ?? 0) + 1;
    }
    return m;
  }

  /// (label, count) buckets of average cycle length.
  List<(String, int)> get lengthBuckets {
    final buckets = [
      ('≤ 26 days', 0),
      ('27-29 days', 0),
      ('30-32 days', 0),
      ('≥ 33 days', 0),
    ];
    for (final u in users) {
      final l = u.averageCycleLength;
      if (l <= 26) {
        buckets[0] = (buckets[0].$1, buckets[0].$2 + 1);
      } else if (l <= 29) {
        buckets[1] = (buckets[1].$1, buckets[1].$2 + 1);
      } else if (l <= 32) {
        buckets[2] = (buckets[2].$1, buckets[2].$2 + 1);
      } else {
        buckets[3] = (buckets[3].$1, buckets[3].$2 + 1);
      }
    }
    return buckets;
  }

  /// (label, count) buckets of user age.
  List<(String, int)> get ageBuckets {
    final now = DateTime.now();
    final buckets = [
      ('< 18', 0),
      ('18-24', 0),
      ('25-34', 0),
      ('35-44', 0),
      ('45+', 0),
    ];
    for (final u in users) {
      final by = u.birthYear;
      if (by == null) continue;
      final age = now.year - by;
      if (age < 18) {
        buckets[0] = (buckets[0].$1, buckets[0].$2 + 1);
      } else if (age <= 24) {
        buckets[1] = (buckets[1].$1, buckets[1].$2 + 1);
      } else if (age <= 34) {
        buckets[2] = (buckets[2].$1, buckets[2].$2 + 1);
      } else if (age <= 44) {
        buckets[3] = (buckets[3].$1, buckets[3].$2 + 1);
      } else {
        buckets[4] = (buckets[4].$1, buckets[4].$2 + 1);
      }
    }
    return buckets;
  }

  List<AppUser> get lookup {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return users.toList();
    return users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.uid.contains(q))
        .toList();
  }
}
