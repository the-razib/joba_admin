import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
import 'package:joba_admin/features/reports/models/report.dart';

void main() {
  late MockReportRepository mockRepo;
  late ReportsController controller;

  setUp(() async {
    Get.testMode = true;
    Get.put(ThemeService());
    mockRepo = MockReportRepository();
    Get.put<ReportRepository>(mockRepo);
    controller = Get.put(ReportsController());
    await controller.loadReports();
  });

  tearDown(() {
    Get.reset();
  });

  test('ReportsController loads initial seed reports', () async {
    expect(controller.loading.value, isFalse);
    expect(controller.all, isNotEmpty);
    expect(controller.all.length, 6);
  });

  test('ReportsController filters reports by typeTab and search', () async {
    controller.typeTab.value = 'Bug Reports';
    final bugs = controller.filtered;
    expect(bugs.every((r) => r.type == ReportType.bug), isTrue);

    controller.typeTab.value = 'All Reports';
    controller.searchController.text = 'Notification';
    final searchResults = controller.filtered;
    expect(searchResults.length, 1);
    expect(searchResults.first.subject, contains('Notification'));
  });

  test('ReportsController updates report status', () async {
    final firstId = controller.all.first.id;
    await controller.updateStatus(firstId, ReportStatus.resolved);
    final updated = controller.all.firstWhere((r) => r.id == firstId);
    expect(updated.status, ReportStatus.resolved);
  });

  test('ReportsController updates report priority', () async {
    final firstId = controller.all.first.id;
    await controller.updatePriority(firstId, ReportPriority.low);
    final updated = controller.all.firstWhere((r) => r.id == firstId);
    expect(updated.priority, ReportPriority.low);
  });

  test('ReportsController deletes report', () async {
    final initialCount = controller.all.length;
    final firstId = controller.all.first.id;
    await controller.deleteReport(firstId);
    expect(controller.all.length, initialCount - 1);
    expect(controller.all.any((r) => r.id == firstId), isFalse);
  });
}
