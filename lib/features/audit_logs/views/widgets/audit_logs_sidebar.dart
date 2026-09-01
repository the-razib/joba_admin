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
            () {
              if (controller.all.isEmpty) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    'No activity logs recorded yet',
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return ActivityLineChart(
                values: controller.activityValues,
                labels: controller.activityLabels,
                height: 160,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Action Breakdown',
          child: Obx(
            () {
              if (controller.all.isEmpty) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    'No actions recorded yet',
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }

              final createdCount = controller.countAction(AuditAction.created);
              final updatedCount = controller.countAction(AuditAction.updated);
              final deletedCount = controller.countAction(AuditAction.deleted);
              final viewedCount = controller.countAction(AuditAction.viewed);
              final othersCount = controller.countAction(AuditAction.downloaded) +
                  controller.countAction(AuditAction.exported) +
                  controller.countAction(AuditAction.failedLogin);

              final slices = <DonutSlice>[
                if (createdCount > 0)
                  DonutSlice('Created', createdCount.toDouble(), AppColors.primary),
                if (updatedCount > 0)
                  DonutSlice('Updated', updatedCount.toDouble(), AppColors.info),
                if (deletedCount > 0)
                  DonutSlice('Deleted', deletedCount.toDouble(), AppColors.accent),
                if (viewedCount > 0)
                  DonutSlice('Viewed', viewedCount.toDouble(), AppColors.warning),
                if (othersCount > 0)
                  DonutSlice('Others', othersCount.toDouble(), const Color(0xFF9AA5A1)),
              ];

              if (slices.isEmpty) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    'No action breakdown available',
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }

              return DonutChart(
                centerValue: '${controller.all.length}',
                centerLabel: 'Total Logs',
                size: 150,
                slices: slices,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final latest = controller.all.isEmpty
              ? null
              : (controller.filtered.isNotEmpty
                  ? controller.filtered.first
                  : controller.all.first);
          if (latest == null) {
            return SectionCard(
              title: 'Recent Log Details',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'No audit records found',
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }

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
