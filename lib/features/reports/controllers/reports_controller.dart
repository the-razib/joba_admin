import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/reports/models/report.dart';

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
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      loading.value = true;
      final reports = await repo.fetchReports();
      all.assignAll(reports);
    } catch (e) {
      AppToast.error('Load Failed', 'Could not load reports: $e');
    } finally {
      loading.value = false;
    }
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
              r.userEmail.toLowerCase().contains(q) ||
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

  Future<void> updateStatus(String id, ReportStatus status) async {
    final i = all.indexWhere((r) => r.id == id);
    if (i >= 0) {
      final old = all[i];
      all[i] = old.copyWith(status: status);
      try {
        await repo.updateReportStatus(id, status);
        AppToast.success(
          'Status Updated',
          'Report marked as ${status.displayName}.',
        );
      } catch (e) {
        all[i] = old;
        AppToast.error('Update Failed', 'Could not update status: $e');
      }
    }
  }

  Future<void> updatePriority(String id, ReportPriority priority) async {
    final i = all.indexWhere((r) => r.id == id);
    if (i >= 0) {
      final old = all[i];
      all[i] = old.copyWith(priority: priority);
      try {
        await repo.updateReportPriority(id, priority);
        AppToast.success(
          'Priority Updated',
          'Report priority set to ${priority.displayName}.',
        );
      } catch (e) {
        all[i] = old;
        AppToast.error('Update Failed', 'Could not update priority: $e');
      }
    }
  }

  Future<void> markAsRead(String id) async {
    final i = all.indexWhere((r) => r.id == id);
    if (i >= 0 && !all[i].isRead) {
      all[i] = all[i].copyWith(isRead: true);
      try {
        await repo.markAsRead(id);
      } catch (_) {}
    }
  }

  Future<void> deleteReport(String id) async {
    final i = all.indexWhere((r) => r.id == id);
    if (i >= 0) {
      final removed = all.removeAt(i);
      try {
        await repo.deleteReport(id);
        AppToast.success('Report Deleted', 'Report removed successfully.');
      } catch (e) {
        all.insert(i, removed);
        AppToast.error('Delete Failed', 'Could not delete report: $e');
      }
    }
  }
}
