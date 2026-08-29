import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
import 'package:joba_admin/features/reports/views/widgets/report_detail_panel.dart';
import 'package:joba_admin/features/reports/views/widgets/report_type_icon.dart';
import 'package:joba_admin/features/reports/views/widgets/reports_mobile_card.dart';
import 'package:joba_admin/features/reports/views/widgets/reports_type_tabs.dart';

/// Card containing type filter tabs, search and status filter bar, and the adaptive reports data table.
class ReportsTableCard extends GetView<ReportsController> {
  const ReportsTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ReportsTypeTabs(),
          Divider(height: 1, color: context.palette.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilterBar(
              searchController: controller.searchController,
              searchHint: 'Search by user, type, or subject...',
              onSearchChanged: (_) => controller.searchTick.value++,
              filters: [
                FilterOption(
                  label: 'All Status',
                  options: const [
                    'All Status',
                    'Pending',
                    'In Progress',
                    'Resolved',
                  ],
                  selected: controller.statusFilter.value,
                  onChanged: (v) => controller.statusFilter.value = v,
                ),
              ],
            ),
          ),
          Obx(() {
            controller.searchTick.value;
            final list = controller.filtered;
            return AdaptiveDataTable<Report>(
              rows: list,
              onRowTap: (r) => openReportDetailPanel(context, r.id),
              cardBuilder: (context, r) => ReportsMobileCard(
                report: r,
                onTap: () => openReportDetailPanel(context, r.id),
              ),
              columns: [
                AdaptiveColumn<Report>(
                  label: 'Report',
                  flex: 8,
                  build: (context, r) => Row(
                    children: [
                      ReportTypeIcon(type: r.type),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (!r.isRead) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                                Expanded(
                                  child: Text(
                                    r.subject,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.palette.textPrimary,
                                      fontSize: 13,
                                      fontWeight: r.isRead
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.palette.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<Report>(
                  label: 'Type',
                  flex: 4,
                  tabletHidden: true,
                  build: (context, r) => reportTypeBadge(r.type),
                ),
                AdaptiveColumn<Report>(
                  label: 'User',
                  flex: 5,
                  build: (context, r) => Row(
                    children: [
                      AvatarCircle(name: r.userName, size: 30),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.textPrimary,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<Report>(
                  label: 'Status',
                  flex: 3,
                  build: (context, r) => reportStatusBadge(r.status),
                ),
                AdaptiveColumn<Report>(
                  label: 'Priority',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, r) => reportPriorityBadge(r.priority),
                ),
                AdaptiveColumn<Report>(
                  label: 'Date',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, r) => Text(
                    formatDate(r.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                AdaptiveColumn<Report>(
                  label: '',
                  width: 44,
                  align: Alignment.centerRight,
                  build: (context, r) => IconButton(
                    tooltip: 'View',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    onPressed: () => openReportDetailPanel(context, r.id),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
