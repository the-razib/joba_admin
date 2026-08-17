import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/audit_logs/controllers/audit_logs_controller.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_action_badge.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_log_detail_panel.dart';

/// Right-hand sidebar displaying activity line chart, action donut breakdown, and recent log highlight.
class AuditLogsSidebar extends GetView<AuditLogsController> {
  const AuditLogsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          title: 'Activity Overview',
          child: Obx(
            () => ActivityLineChart(
              values: controller.activityValues.isEmpty
                  ? const [1, 2, 3]
                  : controller.activityValues,
              labels: controller.activityLabels.isEmpty
                  ? const ['a', 'b', 'c']
                  : controller.activityLabels,
              height: 160,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Action Breakdown',
          child: Obx(
            () => DonutChart(
              centerValue: '${controller.all.length}',
              centerLabel: 'Total Logs',
              size: 150,
              slices: [
                DonutSlice(
                  'Created',
                  controller.countAction(AuditAction.created).toDouble(),
                  AppColors.primary,
                ),
                DonutSlice(
                  'Updated',
                  controller.countAction(AuditAction.updated).toDouble(),
                  AppColors.info,
                ),
                DonutSlice(
                  'Deleted',
                  controller.countAction(AuditAction.deleted).toDouble(),
                  AppColors.accent,
                ),
                DonutSlice(
                  'Viewed',
                  controller.countAction(AuditAction.viewed).toDouble(),
                  AppColors.warning,
                ),
                DonutSlice(
                  'Others',
                  (controller.countAction(AuditAction.downloaded) +
                          controller.countAction(AuditAction.exported) +
                          controller.countAction(AuditAction.failedLogin))
                      .toDouble(),
                  const Color(0xFF9AA5A1),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final latest = controller.all.isEmpty
              ? null
              : (controller.filtered.isNotEmpty
                  ? controller.filtered.first
                  : controller.all.first);
          if (latest == null) return const SizedBox();

          return SectionCard(
            title: 'Recent Log Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        latest.details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AuditActionBadge(action: latest.action),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${latest.adminName} (${latest.adminRole}) • ${latest.ip}',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => openAuditLogDetailPanel(context, latest),
                    child: const Text('View Full Details'),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
