import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/features/reports/views/widgets/reports_mobile_card.dart';
import 'package:joba_admin/features/reports/views/widgets/reports_table_card.dart';

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

  test('ReportsController marks report as read', () async {
    final unread = controller.all.firstWhere((r) => !r.isRead);
    expect(unread.isRead, isFalse);

    await controller.markAsRead(unread.id);

    final updated = controller.all.firstWhere((r) => r.id == unread.id);
    expect(updated.isRead, isTrue);
  });

  testWidgets('ReportsTableCard renders red NEW badge on unread reports', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: ReportsTableCard(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final newBadges = find.text('NEW');
    expect(newBadges, findsWidgets);

    final container = tester.widget<Container>(
      find.ancestor(of: newBadges.first, matching: find.byType(Container)).first,
    );
    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.color, AppColors.danger);
  });

  testWidgets('ReportsMobileCard renders red NEW badge on unread report', (tester) async {
    final unreadReport = controller.all.firstWhere((r) => !r.isRead);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: ReportsMobileCard(
            report: unreadReport,
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final newBadge = find.text('NEW');
    expect(newBadge, findsOneWidget);

    final container = tester.widget<Container>(
      find.ancestor(of: newBadge, matching: find.byType(Container)).first,
    );
    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.color, AppColors.danger);
  });
}


