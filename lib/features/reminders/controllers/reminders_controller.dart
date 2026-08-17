import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';

class RemindersController extends GetxController {
  final UserRepository repo = Get.find();

  static const _defaultOrder = [
    ReminderKind.pad,
    ReminderKind.periodPrep,
    ReminderKind.medicine,
  ];

  final loading = true.obs;
  final saving = false.obs;
  final users = <AppUser>[].obs;

  /// Global home-screen planning order shipped to all users.
  /// Admins rearrange it; user home screens render their tracked
  /// reminders in this sequence.
  final order = <ReminderKind>[..._defaultOrder].obs;

  /// Baseline the draft [order] is compared against to detect edits.
  final _savedOrder = <ReminderKind>[..._defaultOrder].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    users.assignAll(await repo.seedUsers());
    loading.value = false;
  }

  bool get isDirty => !listEquals(order, _savedOrder);

  /// Users tracking at least one reminder.
  int get trackerCount => users.where((u) => u.reminders.isNotEmpty).length;

  int get notTrackingCount => users.length - trackerCount;

  /// Share of the whole user base with at least one reminder, 0-100.
  double get adoptionPercent =>
      users.isEmpty ? 0 : trackerCount / users.length * 100;

  /// Average number of reminders tracked per tracking user.
  double get avgPerTracker {
    if (trackerCount == 0) return 0;
    final total = users.fold<int>(0, (sum, u) => sum + u.reminders.length);
    return total / trackerCount;
  }

  int trackersOf(ReminderKind kind) =>
      users.where((u) => u.reminders.contains(kind)).length;

  /// Share of the whole user base tracking [kind], 0-100.
  double adoptionOf(ReminderKind kind) =>
      users.isEmpty ? 0 : trackersOf(kind) / users.length * 100;

  /// How many users track each reminder kind, in home-screen order.
  List<(ReminderKind, int)> get kindCounts => [
    for (final k in order) (k, trackersOf(k)),
  ];

  /// Reorder callback for [ReorderableListView], which reports the
  /// insertion slot rather than the final index.
  void move(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= order.length) return;
    if (newIndex < 0 || newIndex >= order.length) return;
    order.insert(newIndex, order.removeAt(oldIndex));
  }

  void moveUp(int index) => _swap(index, index - 1);

  void moveDown(int index) => _swap(index, index + 1);

  void _swap(int a, int b) {
    if (a < 0 || b < 0 || a >= order.length || b >= order.length) return;
    final item = order[a];
    order[a] = order[b];
    order[b] = item;
  }

  void resetOrder() => order.assignAll(_savedOrder);

  Future<void> saveOrder() async {
    saving.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _savedOrder.assignAll(order);
    saving.value = false;
    Get.snackbar(
      'Reminder order saved',
      'Every user\'s home screen now plans reminders in this sequence (mock).',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
