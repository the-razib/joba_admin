import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';

class ReportsController extends GetxController {
  final ReportRepository repo = Get.find();

  final loading = true.obs;
  final all = <Report>[].obs;
  final typeTab = 'All Reports'.obs;
  final searchController = TextEditingController();
  final searchTick = 0.obs;
  final statusFilter = 'All Status'.obs;

  static const typeTabs = [
    'All Reports',
    'Bug Reports',
    'Prediction Issues',
    'Content Issues',
    'Feature Requests',
    'Other Feedback',
  ];

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    all.assignAll(await repo.seedReports());
    loading.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  int countStatus(ReportStatus s) => all.where((r) => r.status == s).length;

  List<Report> get filtered {
    var list = all.toList();
    switch (typeTab.value) {
      case 'Bug Reports':
        list = list.where((r) => r.type == ReportType.bug).toList();
      case 'Prediction Issues':
        list = list.where((r) => r.type == ReportType.prediction).toList();
      case 'Content Issues':
        list = list.where((r) => r.type == ReportType.content).toList();
      case 'Feature Requests':
        list = list.where((r) => r.type == ReportType.feature).toList();
      case 'Other Feedback':
        list = list
            .where((r) =>
                r.type == ReportType.other || r.type == ReportType.payment)
            .toList();
      default:
        break;
    }
    final q = searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((r) =>
              r.subject.toLowerCase().contains(q) ||
              r.userName.toLowerCase().contains(q) ||
              r.description.toLowerCase().contains(q))
          .toList();
    }
    if (statusFilter.value != 'All Status') {
      list = list.where((r) {
        final s = statusFilter.value.toLowerCase();
        return r.status.name.toLowerCase() == s.replaceAll(' ', '_') ||
            (s == 'in progress' && r.status == ReportStatus.inProgress);
      }).toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void updateStatus(String id, ReportStatus status) {
    final i = all.indexWhere((r) => r.id == id);
    if (i >= 0) all[i] = all[i].copyWith(status: status);
  }
}
