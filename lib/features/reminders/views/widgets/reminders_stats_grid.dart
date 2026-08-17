import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';

/// Responsive grid of 4 KPI statistics for the Reminders section.
class RemindersStatsGrid extends GetView<RemindersController> {
  const RemindersStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = <(IconData, String, String, Color)>[
        (
          Icons.alarm_on_outlined,
          'Active Trackers',
          '${controller.trackerCount}',
          AppColors.purple,
        ),
        (
          Icons.groups_outlined,
          'Tracker Adoption',
          '${controller.adoptionPercent.toStringAsFixed(0)}%',
          AppColors.info,
        ),
        (
          Icons.layers_outlined,
          'Avg. per Tracker',
          controller.avgPerTracker.toStringAsFixed(1),
          AppColors.success,
        ),
        (
          Icons.notifications_off_outlined,
          'Not Tracking',
          '${controller.notTrackingCount}',
          AppColors.danger,
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
          iconColor: stats[i].$4,
        ),
      );
    });
  }
}
