import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/cycle_data/controllers/cycle_data_controller.dart';

/// Card displaying the donut chart breakdown of user cycle goals.
class CycleGoalsCard extends GetView<CycleDataController> {
  const CycleGoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Cycle Goals',
      child: Obx(
        () => DonutChart(
          centerValue: '${controller.users.length}',
          centerLabel: 'Users',
          size: 160,
          slices: [
            DonutSlice(
              'Track',
              (controller.goalCounts['track'] ?? 0).toDouble(),
              AppColors.primary,
            ),
            DonutSlice(
              'Conceive',
              (controller.goalCounts['conceive'] ?? 0).toDouble(),
              AppColors.accent,
            ),
            DonutSlice(
              'Avoid',
              (controller.goalCounts['avoid'] ?? 0).toDouble(),
              AppColors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
