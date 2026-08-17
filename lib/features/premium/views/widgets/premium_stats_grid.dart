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
          '${controller.users.length}',
          10.1,
          'vs last 7 days',
          AppColors.warning,
        ),
        (
          Icons.payments_outlined,
          'Revenue (30d)',
          '৳${compactNumber(controller.monthlyRevenue)}',
          14.8,
          'vs last 30 days',
          AppColors.primary,
        ),
        (
          Icons.local_offer_outlined,
          'Active Promos',
          '${controller.promos.where((p) => p.active).length}',
          null,
          '',
          AppColors.accent,
        ),
        (
          Icons.receipt_outlined,
          'Transactions',
          '${controller.transactions.length}',
          6.2,
          'vs last 7 days',
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
