import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/audit_log.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';

class AuditLogsController extends GetxController {
  final AuditLogRepository repo = Get.find();

  final loading = true.obs;
  final all = <AuditLog>[].obs;
  final searchController = TextEditingController();
  final searchTick = 0.obs;
  final moduleFilter = 'All Modules'.obs;
  final actionFilter = 'All Actions'.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    all.assignAll(await repo.seedLogs());
    loading.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<String> get modules => [
    'All Modules',
    ...all.map((l) => l.module).toSet().toList()..sort(),
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

  int countAction(AuditAction a) => all.where((l) => l.action == a).length;

  int get securityEvents =>
      all.where((l) => l.action == AuditAction.failedLogin).length;

  List<double> get activityValues {
    final byDay = <int, int>{};
    for (final l in all) {
      final d = DateTime(l.time.year, l.time.month, l.time.day);
      byDay[d.millisecondsSinceEpoch] =
          (byDay[d.millisecondsSinceEpoch] ?? 0) + 1;
    }
    final days = <int>[...byDay.keys]..sort();
    return days.map((d) => (byDay[d] ?? 0) * 900.0).toList();
  }

  List<String> get activityLabels {
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
