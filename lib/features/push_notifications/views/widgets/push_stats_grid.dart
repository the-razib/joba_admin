import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';

/// Responsive grid of 4 KPI statistics for Push Notifications.
///
/// Every figure here is derived from real dispatch results written by the
/// `adminSendPush` Cloud Function.
///
/// There is deliberately no "Delivered" or "Opened" card. FCM's HTTP v1 response
/// reports only whether it ACCEPTED a message for a token — not whether the
/// handset received it, and never whether the user opened it. Those require an
/// Analytics/BigQuery export this project does not have, so showing them would
/// mean inventing numbers. The trend deltas were removed for the same reason:
/// nothing stores a previous period to compare against.
class PushStatsGrid extends GetView<PushController> {
  const PushStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = <(IconData, String, String, Color)>[
        (
          Icons.campaign_outlined,
          'Campaigns Sent',
          '${controller.sentCampaignCount}',
          AppColors.primary,
        ),
        (
          Icons.send_outlined,
          'Devices Accepted',
          compactNumber(controller.totalAccepted),
          AppColors.info,
        ),
        (
          Icons.error_outline,
          'Devices Rejected',
          compactNumber(controller.totalRejected),
          AppColors.accent,
        ),
        (
          Icons.show_chart,
          'Acceptance Rate',
          '${controller.acceptanceRate.toStringAsFixed(1)}%',
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
          iconColor: stats[i].$4,
        ),
      );
    });
  }
}
