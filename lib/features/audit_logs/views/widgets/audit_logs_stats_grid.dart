import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/audit_logs/controllers/audit_logs_controller.dart';

/// Responsive grid of 4 KPI statistics for Audit & Security Logs.
class AuditLogsStatsGrid extends GetView<AuditLogsController> {
  const AuditLogsStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = [
        (
          Icons.receipt_long_outlined,
          'Total Logs',
          '18,742',
          18.6,
          'vs last 7 days',
          AppColors.primary,
        ),
        (
          Icons.group_outlined,
          'Users',
          '6,421',
          12.4,
          'vs last 7 days',
          AppColors.purple,
        ),
        (
          Icons.settings_outlined,
          'Admin Actions',
          '9,356',
          15.3,
          'vs last 7 days',
          AppColors.warning,
        ),
        (
          Icons.verified_user_outlined,
          'Security Events',
          '${controller.securityEvents + 960}',
          22.7,
          'vs last 7 days',
          AppColors.info,
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
