import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';

/// Responsive grid of 5 live KPI statistics for the main admin overview dashboard.
class DashboardStatsGrid extends GetView<DashboardController> {
  const DashboardStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.kpiStats;
      final count = Responsive.pick(context, mobile: 2, tablet: 3, desktop: 5);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
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
