import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';

class AuditLogsController extends GetxController {
  final AuditLogRepository repo = Get.find<AuditLogRepository>();

  final loading = true.obs;
  final all = <AuditLog>[].obs;
  final searchController = TextEditingController();
  final searchTick = 0.obs;
  final moduleFilter = 'All Modules'.obs;
  final actionFilter = 'All Actions'.obs;
  final page = 1.obs;
  final pageSize = 10.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchTick.value++;
      page.value = 1;
    });
    ever(moduleFilter, (_) => page.value = 1);
    ever(actionFilter, (_) => page.value = 1);
    loadLogs();
  }

  Future<void> loadLogs() async {
    loading.value = true;
    AppLoggerHelper.info('[AuditLogsController] 📋 Fetching administrative audit logs (limit: 200)...');
    try {
      final logs = await repo.fetchLogs(limit: 200);
      all.assignAll(logs);
      AppLoggerHelper.success('AuditLogsController', 'Loaded ${logs.length} audit log entries');
    } catch (e, st) {
      AppLoggerHelper.failure('AuditLogsController', 'Failed to fetch audit logs: $e', error: e, stackTrace: st);
      all.clear();
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshLogs() => loadLogs();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<String> get modules => [
    'All Modules',
    ...all.map((l) => l.module).where((m) => m.isNotEmpty).toSet().toList()..sort(),
  ];

  static const actionOptions = [
    'All Actions',
    'Created',
    'Updated',
    'Deleted',
    'Viewed',
    'Downloaded',
    'Exported',
    'Failed Login',
  ];

  List<AuditLog> get filtered {
    var list = all.toList();
    final q = searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (l) =>
                l.adminName.toLowerCase().contains(q) ||
                l.details.toLowerCase().contains(q) ||
                l.module.toLowerCase().contains(q) ||
                l.ip.contains(q),
          )
          .toList();
    }
    if (moduleFilter.value != 'All Modules') {
      list = list.where((l) => l.module == moduleFilter.value).toList();
    }
    if (actionFilter.value != 'All Actions') {
      list = list
          .where(
            (l) =>
                l.action.name.toLowerCase() ==
                actionFilter.value.toLowerCase().replaceAll(' ', ''),
          )
          .toList();
    }
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  List<AuditLog> get paginated {
    final list = filtered;
    final start = (page.value - 1) * pageSize.value;
    if (start >= list.length) {
      if (list.isEmpty) return [];
      // Adjust page if it was out of bounds
      final maxPage = (list.length / pageSize.value).ceil();
      final adjustedStart = (maxPage - 1) * pageSize.value;
      return list.sublist(adjustedStart);
    }
    final end = (start + pageSize.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int countAction(AuditAction a) => all.where((l) => l.action == a).length;

  int get userEventsCount =>
      all.where((l) => l.module.toLowerCase().contains('user')).length;

  int get adminActionsCount => all
      .where((l) =>
          l.action == AuditAction.created ||
          l.action == AuditAction.updated ||
          l.action == AuditAction.deleted)
      .length;

  int get securityEvents => all
      .where((l) =>
          l.action == AuditAction.failedLogin ||
          l.status == AuditStatus.failed ||
          l.module.toLowerCase().contains('auth'))
      .length;

  double get last7DaysPercent {
    if (all.isEmpty) return 0.0;
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7));
    final recent = all.where((l) => l.time.isAfter(cutoff)).length;
    return (recent / all.length) * 100;
  }

  List<double> get activityValues {
    if (all.isEmpty) return [];
    final byDay = <int, int>{};
    for (final l in all) {
      final d = DateTime(l.time.year, l.time.month, l.time.day);
      byDay[d.millisecondsSinceEpoch] =
          (byDay[d.millisecondsSinceEpoch] ?? 0) + 1;
    }
    final days = <int>[...byDay.keys]..sort();
    return days.map((d) => (byDay[d] ?? 0).toDouble()).toList();
  }

  List<String> get activityLabels {
    if (all.isEmpty) return [];
    final days = <int>[
      for (final l in all)
        DateTime(l.time.year, l.time.month, l.time.day).millisecondsSinceEpoch,
    ]..sort();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return [
      for (final ms in days.toSet())
        '${DateTime.fromMillisecondsSinceEpoch(ms).day} ${months[DateTime.fromMillisecondsSinceEpoch(ms).month - 1]}',
    ];
  }
}
