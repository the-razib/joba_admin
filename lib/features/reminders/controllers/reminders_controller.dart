import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/config_repository.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/core/utils/app_toast.dart';

class RemindersController extends GetxController {
  final UserRepository userRepo = Get.find();
  final ConfigRepository configRepo = Get.find();

  static const _defaultOrder = [
    ReminderKind.pad,
    ReminderKind.periodPrep,
    ReminderKind.medicine,
  ];

  final loading = true.obs;
  final saving = false.obs;
  final users = <AppUser>[].obs;
  final totalUsersCount = 0.obs;
  final totalTrackers = 0.obs;
  final kindTrackerCounts = <ReminderKind, int>{}.obs;

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
    AppLoggerHelper.info('[RemindersController] ⏰ Loading reminders config and user adoption stats...');
    try {
      final fetchedUsers = await userRepo.fetchUsers();
      users.assignAll(fetchedUsers);
      totalUsersCount.value = fetchedUsers.length;

      // 1. Load reminders sequence
      final remindersConfig = await configRepo.getDoc('reminders');
      if (remindersConfig != null && remindersConfig['order'] is List) {
        final List<dynamic> rawList = remindersConfig['order'] as List<dynamic>;
        final parsedOrder = <ReminderKind>[];
        for (final item in rawList) {
          final kind = ReminderKind.values.firstWhereOrNull(
            (k) => k.name.toLowerCase() == item.toString().toLowerCase(),
          );
          if (kind != null && !parsedOrder.contains(kind)) {
            parsedOrder.add(kind);
          }
        }
        for (final kind in _defaultOrder) {
          if (!parsedOrder.contains(kind)) parsedOrder.add(kind);
        }
        order.assignAll(parsedOrder);
        _savedOrder.assignAll(parsedOrder);
      }

      // 2. Compute accurate live metrics across all categories & sync reminder_stats
      final computedTrackers =
          users.where((u) => u.reminders.isNotEmpty).length;
      final padC =
          users.where((u) => u.reminders.contains(ReminderKind.pad)).length;
      final prepC = users
          .where((u) => u.reminders.contains(ReminderKind.periodPrep))
          .length;
      final medC = users
          .where((u) => u.reminders.contains(ReminderKind.medicine))
          .length;

      totalTrackers.value = computedTrackers;
      kindTrackerCounts[ReminderKind.pad] = padC;
      kindTrackerCounts[ReminderKind.periodPrep] = prepC;
      kindTrackerCounts[ReminderKind.medicine] = medC;

      AppLoggerHelper.success(
        'RemindersController',
        'Loaded order: ${order.map((k) => k.name).toList()} (Pad: $padC, Prep: $prepC, Medicine: $medC, Total tracking: $computedTrackers)',
      );

      unawaited(configRepo.saveDoc('reminder_stats', {
        'totalTrackers': computedTrackers,
        'padCount': padC,
        'periodPrepCount': prepC,
        'medicineCount': medC,
      }));
    } catch (e, st) {
      AppLoggerHelper.failure('RemindersController', 'Error loading reminders config: $e', error: e, stackTrace: st);
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _load();
  }

  bool get isDirty => !listEquals(order, _savedOrder);

  /// Users tracking at least one reminder.
  int get trackerCount => totalTrackers.value > 0
      ? totalTrackers.value
      : users.where((u) => u.reminders.isNotEmpty).length;

  int get notTrackingCount => totalUsersCount.value > trackerCount
      ? totalUsersCount.value - trackerCount
      : 0;

  /// Share of the whole user base with at least one reminder, 0-100.
  double get adoptionPercent => totalUsersCount.value == 0
      ? 0
      : (trackerCount / totalUsersCount.value * 100).clamp(0.0, 100.0);

  /// Average number of reminders tracked per tracking user.
  double get avgPerTracker {
    if (trackerCount == 0) return 0;
    final totalReminders = kindTrackerCounts.values.fold<int>(0, (a, b) => a + b);
    return totalReminders > 0 ? (totalReminders / trackerCount) : 1.0;
  }

  int trackersOf(ReminderKind kind) =>
      kindTrackerCounts[kind] ??
      users.where((u) => u.reminders.contains(kind)).length;

  /// Share of the whole user base tracking [kind], 0-100.
  double adoptionOf(ReminderKind kind) => totalUsersCount.value == 0
      ? 0
      : (trackersOf(kind) / totalUsersCount.value * 100).clamp(0.0, 100.0);

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
    final orderNames = order.map((k) => k.name).toList();
    AppLoggerHelper.info('[RemindersController] 💾 Saving reminder sequence: $orderNames');
    try {
      await configRepo.saveDoc('reminders', {
        'order': orderNames,
      });
      _savedOrder.assignAll(order);
      AppLoggerHelper.success('RemindersController', 'Reminder sequence saved: $orderNames');
      AppToast.success(
        'Reminder order saved',
        'Mobile app home screens will reflect this reminder sequence on next launch.',
      );
    } catch (e, st) {
      AppLoggerHelper.failure('RemindersController', 'Could not save reminder sequence: $e', error: e, stackTrace: st);
      AppToast.error('Save failed', 'Could not save reminder sequence: $e');
    } finally {
      saving.value = false;
    }
  }
}
