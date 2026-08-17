import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';

/// Responsive grid of 5 KPI statistics for Firebase resource consumption and projected spend.
class UsageKpiGrid extends GetView<UsageController> {
  const UsageKpiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final w = controller.window;
      final latest = controller.latest;

      final cards = <(IconData, String, String, double?, String, Color)>[
        (
          Icons.menu_book_outlined,
          'Document reads',
          compactNumber(controller.totalReads(w)),
          controller.readsDeltaPercent,
          'vs previous period',
          AppColors.primary,
        ),
        (
          Icons.edit_note_outlined,
          'Document writes',
          compactNumber(controller.totalWrites(w)),
          controller.writesDeltaPercent,
          'vs previous period',
          AppColors.purple,
        ),
        (
          Icons.folder_outlined,
          'Storage used',
          latest == null ? '—' : dataSizeLabel(latest.storedBytes),
          controller.storageDeltaPercent,
          'Firestore + Cloud Storage',
          AppColors.info,
        ),
        (
          Icons.cloud_download_outlined,
          'Network egress',
          dataSizeLabel(controller.totalEgress(w)),
          controller.egressDeltaPercent,
          'vs previous period',
          AppColors.accent,
        ),
        (
          Icons.payments_outlined,
          'Projected this month',
          usd(controller.projectedMonthCost),
          controller.costDeltaPercent,
          'month-to-date + forecast',
          AppColors.warning,
        ),
      ];

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
        itemCount: cards.length,
        itemBuilder: (_, i) => StatCard(
          icon: cards[i].$1,
          label: cards[i].$2,
          value: cards[i].$3,
          deltaPercent: cards[i].$4,
          compareLabel: cards[i].$5,
          iconColor: cards[i].$6,
        ),
      );
    });
  }
}
