import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';

/// Responsive grid of 4 KPI statistics for the Reports & Feedback section.
class ReportsStatsGrid extends GetView<ReportsController> {
  const ReportsStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = [
        (
          Icons.rate_review_outlined,
          'Total Reports',
          '${controller.all.length}',
          AppColors.accent,
        ),
        (
          Icons.pending_outlined,
          'Pending',
          '${controller.countStatus(ReportStatus.pending)}',
          AppColors.warning,
        ),
        (
          Icons.hourglass_top_outlined,
          'In Progress',
          '${controller.countStatus(ReportStatus.inProgress)}',
          AppColors.purple,
        ),
        (
          Icons.task_alt_outlined,
          'Resolved',
          '${controller.countStatus(ReportStatus.resolved)}',
          AppColors.success,
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
          mainAxisExtent: 96,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => StatCard(
          icon: stats[i].$1,
          label: stats[i].$2,
          value: stats[i].$3,
          iconColor: stats[i].$4,
        ),
      );
    });
  }
}
