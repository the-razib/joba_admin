import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';

/// Responsive grid of 4 KPI statistics for Push Notifications.
class PushStatsGrid extends GetView<PushController> {
  const PushStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = <(IconData, String, String, double?, String, Color)>[
        (
          Icons.send_outlined,
          'Total Sent',
          '${controller.sentCount}',
          8.1,
          'vs last 7 days',
          AppColors.primary,
        ),
        (
          Icons.mark_chat_read_outlined,
          'Delivered',
          compactNumber(controller.totalDelivered),
          5.4,
          'vs last 7 days',
          AppColors.info,
        ),
        (
          Icons.touch_app_outlined,
          'Opened',
          compactNumber(controller.totalOpened),
          11.2,
          'vs last 7 days',
          AppColors.accent,
        ),
        (
          Icons.show_chart,
          'Open Rate',
          '${controller.openRate.toStringAsFixed(1)}%',
          2.3,
          'vs last 7 days',
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
