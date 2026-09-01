import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';

/// Responsive grid of 4 KPI statistics for Premium & Payments.
class PremiumStatsGrid extends GetView<PremiumController> {
  const PremiumStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = [
        (
          Icons.workspace_premium_outlined,
          'Premium Users',
          '${controller.premiumUsersCount}',
          null,
          'active subscribers',
          AppColors.warning,
        ),
        (
          Icons.payments_outlined,
          'Revenue (All time)',
          '৳${compactNumber(controller.monthlyRevenue)}',
          null,
          'total gross payments',
          AppColors.primary,
        ),
        (
          Icons.local_offer_outlined,
          'Active Promos',
          '${controller.activePromosCount}',
          null,
          'of ${controller.promos.length} total codes',
          AppColors.accent,
        ),
        (
          Icons.receipt_outlined,
          'Transactions',
          '${controller.transactionsCount}',
          null,
          'payment records',
          AppColors.info,
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
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 110,
        ),
        itemCount: stats.length,
        itemBuilder: (context, i) {
          final s = stats[i];
          return StatCard(
            icon: s.$1,
            label: s.$2,
            value: s.$3,
            deltaPercent: s.$4,
            compareLabel: s.$5,
            iconColor: s.$6,
          );
        },
      );
    });
  }
}
