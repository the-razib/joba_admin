import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/audit_logs/controllers/audit_logs_controller.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/audit_logs/views/audit_logs_screen.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_logs_stats_grid.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_logs_table_card.dart';

class EmptyAuditLogRepository implements AuditLogRepository {
  @override
  Future<List<AuditLog>> seedLogs() async => [];

  @override
  Future<List<AuditLog>> fetchLogs({
    int limit = 100,
    String? module,
    String? action,
    String? search,
  }) async => [];

  @override
  Future<void> recordLog(AuditLog log) async {}
}

void main() {
  setUp(() {
    Get.reset();
    Get.put<ThemeService>(ThemeService());
    Get.put<AuditLogRepository>(MockAuditLogRepository());
  });

  group('AuditLog Model Tests', () {
    test('round-trip serialization with all fields', () {
      final now = DateTime(2026, 9, 1, 12, 0);
      final log = AuditLog(
        id: 'AL-999',
        time: now,
        adminName: 'Test Admin',
        adminRole: 'Editor',
        action: AuditAction.updated,
        module: 'Article',
        details: 'Updated article title',
        ip: '192.168.1.1',
        location: 'Dhaka, BD',
        status: AuditStatus.success,
      );

      final map = log.toMap();
      expect(map['adminName'], 'Test Admin');
      expect(map['action'], 'updated');
      expect(map['module'], 'Article');
      expect(map['status'], 'success');

      final parsed = AuditLog.fromMap(map, docId: 'AL-999');
      expect(parsed.id, 'AL-999');
      expect(parsed.adminName, 'Test Admin');
      expect(parsed.adminRole, 'Editor');
      expect(parsed.action, AuditAction.updated);
      expect(parsed.module, 'Article');
      expect(parsed.details, 'Updated article title');
      expect(parsed.status, AuditStatus.success);
    });

    test('AuditAction colors and labels', () {
      expect(AuditAction.created.label, 'Created');
      expect(AuditAction.failedLogin.label, 'Failed Login');
      expect(AuditStatus.success.label, 'Success');
      expect(AuditStatus.failed.label, 'Failed');
    });
  });

  group('AuditLogRepository Tests', () {
    test('MockAuditLogRepository fetchLogs with filters', () async {
      final repo = MockAuditLogRepository();
      final allLogs = await repo.fetchLogs(limit: 50);
      expect(allLogs.isNotEmpty, true);

      final articleLogs = await repo.fetchLogs(module: 'Article');
      for (final l in articleLogs) {
        expect(l.module, 'Article');
      }

      final createdLogs = await repo.fetchLogs(action: 'Created');
      for (final l in createdLogs) {
        expect(l.action, AuditAction.created);
      }

      final searchLogs = await repo.fetchLogs(search: 'Razib');
      expect(searchLogs.any((l) => l.adminName.contains('Razib')), true);
    });
  });

  group('AuditLogsController Tests', () {
    test('initializes and computes stats cleanly', () async {
      final controller = Get.put(AuditLogsController());
      await controller.loadLogs();

      expect(controller.loading.value, false);
      expect(controller.all.isNotEmpty, true);
      expect(controller.modules.contains('All Modules'), true);
      expect(controller.filtered.isNotEmpty, true);
      expect(controller.securityEvents, greaterThanOrEqualTo(1));
      expect(controller.activityValues.isNotEmpty, true);
      expect(controller.activityLabels.isNotEmpty, true);
    });

    test('filters logs by search query, module, and action', () async {
      final controller = Get.put(AuditLogsController());
      await controller.loadLogs();

      controller.searchController.text = 'farhana';
      expect(controller.filtered.every((l) =>
          l.details.toLowerCase().contains('farhana') ||
          l.adminName.toLowerCase().contains('farhana')), true);

      controller.searchController.clear();
      controller.moduleFilter.value = 'Article';
      expect(controller.filtered.every((l) => l.module == 'Article'), true);

      controller.moduleFilter.value = 'All Modules';
      controller.actionFilter.value = 'Created';
      expect(controller.filtered.every((l) => l.action == AuditAction.created), true);
    });
  });

  group('AuditLogsScreen Widget Tests', () {
    Widget buildTestApp(Widget child) {
      return GetMaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );
    }

    testWidgets('renders full AuditLogsScreen without overflowing on desktop',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(AuditLogsController());

      await tester.pumpWidget(buildTestApp(const AuditLogsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Audit Logs'), findsOneWidget);
      expect(find.text('Security events, admin actions and audit trail'), findsOneWidget);
      expect(find.byType(AuditLogsStatsGrid), findsOneWidget);
      expect(find.byType(AuditLogsTableCard), findsOneWidget);
    });

    testWidgets('renders full AuditLogsScreen cleanly on mobile',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(AuditLogsController());

      await tester.pumpWidget(buildTestApp(const AuditLogsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Audit Logs'), findsOneWidget);
      expect(find.byType(AuditLogsTableCard), findsOneWidget);
    });

    testWidgets('renders empty state cleanly when no logs exist in database',
        (tester) async {
      Get.reset();
      Get.put<ThemeService>(ThemeService());
      Get.put<AuditLogRepository>(EmptyAuditLogRepository());

      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(AuditLogsController());

      await tester.pumpWidget(buildTestApp(const AuditLogsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Audit Logs'), findsOneWidget);
      expect(find.text('No audit logs found'), findsOneWidget);
      expect(find.text('No activity logs recorded yet'), findsOneWidget);
      expect(find.text('No actions recorded yet'), findsOneWidget);
      expect(find.text('No audit records found'), findsOneWidget);
    });
  });
}
