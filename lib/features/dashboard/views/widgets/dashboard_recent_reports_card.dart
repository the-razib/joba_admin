import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

/// Card displaying the list of recently submitted user bug/feedback reports.
class DashboardRecentReportsCard extends GetView<DashboardController> {
  const DashboardRecentReportsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();

    return SectionCard(
      title: 'Recent Reports',
      action: 'View All',
      onAction: () => shell.select(NavId.reports),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          for (final r in controller.recentReports)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.rate_review_outlined,
                      size: 18,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  reportStatusBadge(r.status),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
