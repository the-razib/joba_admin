import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/cycle_data/controllers/cycle_data_controller.dart';

/// Responsive grid of 4 KPI statistics for Cycle & Health Data.
class CycleStatsGrid extends GetView<CycleDataController> {
  const CycleStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final goals = controller.goalCounts;
      final stats = [
        (
          Icons.sync_alt,
          'Avg. Cycle Length',
          '${controller.avgCycle.toStringAsFixed(1)}d',
          null,
          'Sample n = ${controller.sampleSize}',
          AppColors.primary,
        ),
        (
          Icons.water_drop_outlined,
          'Avg. Period Duration',
          '${controller.avgPeriod.toStringAsFixed(1)}d',
          null,
          'Sample n = ${controller.sampleSize}',
          AppColors.accent,
        ),
        (
          Icons.flag_outlined,
          'Tracking',
          '${goals['track'] ?? 0}',
          null,
          'users',
          AppColors.info,
        ),
        (
          Icons.child_care_outlined,
          'Conceive / Avoid',
          '${(goals['conceive'] ?? 0) + (goals['avoid'] ?? 0)}',
          null,
          'users',
          AppColors.purple,
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
          compareLabel: stats[i].$5,
          iconColor: stats[i].$6,
        ),
      );
    });
  }
}
