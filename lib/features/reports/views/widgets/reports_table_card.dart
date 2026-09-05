import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/core/widgets/pagination_bar.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/features/reports/views/widgets/report_detail_panel.dart';
import 'package:joba_admin/features/reports/views/widgets/report_type_icon.dart';
import 'package:joba_admin/features/reports/views/widgets/reports_mobile_card.dart';
import 'package:joba_admin/features/reports/views/widgets/reports_type_tabs.dart';

/// Card containing type filter tabs, search and status filter bar, and the adaptive reports data table with pagination.
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
            return AdaptiveDataTable<Report>(
              rows: controller.paginated,
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
                                  reportNewBadge(),
                                  const SizedBox(width: 6),
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
                              '${r.id} · ${r.type.displayName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.palette.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<Report>(
                  label: 'User',
                  flex: 6,
                  build: (context, r) => Row(
                    children: [
                      AvatarCircle(name: r.userName, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.palette.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              r.userEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.palette.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
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
          Obx(() {
            final total = controller.filtered.length;
            if (total == 0) return const SizedBox.shrink();
            return PaginationBar(
              page: controller.page.value,
              totalItems: total,
              pageSize: controller.pageSize.value,
              onPageChanged: (p) => controller.page.value = p,
              onPageSizeChanged: (s) {
                controller.pageSize.value = s;
                controller.page.value = 1;
              },
            );
          }),
        ],
      ),
    );
  }
}
