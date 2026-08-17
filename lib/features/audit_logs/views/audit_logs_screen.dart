import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/audit_logs/controllers/audit_logs_controller.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_logs_sidebar.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_logs_stats_grid.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_logs_table_card.dart';

/// Audit Logs Screen - Security events, admin history, and audit trail dashboard.
class AuditLogsScreen extends GetView<AuditLogsController> {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuditLogsStatsGrid(),
                const SizedBox(height: 16),
                Responsive.isDesktop(context)
                    ? const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: AuditLogsTableCard()),
                          SizedBox(width: 16),
                          Expanded(flex: 1, child: AuditLogsSidebar()),
                        ],
                      )
                    : const Column(
                        children: [
                          AuditLogsTableCard(),
                          SizedBox(height: 16),
                          AuditLogsSidebar(),
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
