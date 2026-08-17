import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/features/audit_logs/controllers/audit_logs_controller.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_action_badge.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_log_detail_panel.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_logs_mobile_card.dart';

/// Card containing filter bar and adaptive data table for system audit and security logs.
class AuditLogsTableCard extends GetView<AuditLogsController> {
  const AuditLogsTableCard({super.key});

  static String _timeOf(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Obx(
              () => FilterBar(
                searchController: controller.searchController,
                searchHint: 'Search by admin, user, action, module or IP...',
                onSearchChanged: (_) => controller.searchTick.value++,
                filters: [
                  FilterOption(
                    label: 'All Modules',
                    options: controller.modules,
                    selected: controller.moduleFilter.value,
                    onChanged: (v) => controller.moduleFilter.value = v,
                  ),
                  FilterOption(
                    label: 'All Actions',
                    options: AuditLogsController.actionOptions,
                    selected: controller.actionFilter.value,
                    onChanged: (v) => controller.actionFilter.value = v,
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            controller.searchTick.value;
            return AdaptiveDataTable<AuditLog>(
              rows: controller.filtered,
              onRowTap: (l) => openAuditLogDetailPanel(context, l),
              cardBuilder: (context, l) => AuditLogsMobileCard(log: l),
              columns: [
                AdaptiveColumn<AuditLog>(
                  label: 'Time',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, l) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDate(l.time),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _timeOf(l.time),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Admin / User',
                  flex: 5,
                  build: (context, l) => Row(
                    children: [
                      AvatarCircle(name: l.adminName, size: 32),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.adminName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.palette.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              l.adminRole,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Action',
                  flex: 3,
                  build: (context, l) => AuditActionBadge(action: l.action),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Module',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, l) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.apps_outlined,
                        size: 14,
                        color: AppColors.purple,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l.module,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Details',
                  flex: 5,
                  build: (context, l) => Text(
                    l.details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'IP Address',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, l) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.ip,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 11.5,
                        ),
                      ),
                      Text(
                        l.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Status',
                  flex: 2,
                  build: (context, l) =>
                      PillBadge(label: l.status.label, color: l.status.color),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
