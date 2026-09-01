import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/audit_logs/controllers/audit_logs_controller.dart';

/// Responsive grid of 4 dynamic KPI statistics for Audit & Security Logs.
class AuditLogsStatsGrid extends GetView<AuditLogsController> {
  const AuditLogsStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.all.length;
      final userOps = controller.userEventsCount;
      final adminOps = controller.adminActionsCount;
      final securityOps = controller.securityEvents;
      final pct7d = controller.last7DaysPercent;

      final stats = [
        (
          Icons.receipt_long_outlined,
          'Total Logs',
          '$total',
          pct7d > 0 ? pct7d : null,
          pct7d > 0 ? 'last 7 days' : 'all records',
          AppColors.primary,
        ),
        (
          Icons.group_outlined,
          'User Events',
          '$userOps',
          total > 0 ? (userOps / total) * 100 : null,
          'of total logs',
          AppColors.purple,
        ),
        (
          Icons.settings_outlined,
          'Admin Mutations',
          '$adminOps',
          total > 0 ? (adminOps / total) * 100 : null,
          'of total logs',
          AppColors.warning,
        ),
        (
          Icons.verified_user_outlined,
          'Security Events',
          '$securityOps',
          total > 0 ? (securityOps / total) * 100 : null,
          'of total logs',
          securityOps > 0 ? AppColors.danger : AppColors.info,
        ),
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.pick(
            context,
            mobile: 2,
            tablet: 4,
            desktop: 4,
          ),
          mainAxisExtent: 104,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => StatCard(
          icon: stats[i].$1,
          label: stats[i].$2,
          value: stats[i].$3,
          deltaPercent: stats[i].$4,
          compareLabel: stats[i].$5,
          iconColor: stats[i].$6,
        ),
      );
    });
  }
}
