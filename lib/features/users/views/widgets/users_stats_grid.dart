import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

/// Responsive grid of 5 KPI statistics for the User Directory computed dynamically from Firestore data.
class UsersStatsGrid extends GetView<UsersController> {
  const UsersStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.all;
      final total = list.length;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final activeToday = list.where((u) {
        return u.lastActive.isAfter(todayStart) ||
            now.difference(u.lastActive).inHours < 24;
      }).length;

      final newToday = list.where((u) {
        return u.joinedAt.isAfter(todayStart) ||
            now.difference(u.joinedAt).inHours < 24;
      }).length;

      final premiumUsers = list.where((u) => u.plan == UserPlan.premium).length;

      final cycleLengths =
          list.map((u) => u.averageCycleLength).where((l) => l > 0).toList();
      final avgCycle = cycleLengths.isNotEmpty
          ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length)
              .toStringAsFixed(1)
          : '0.0';

      final stats = [
        (
          Icons.group_outlined,
          'Total Users',
          '$total',
          null,
          'all registered',
          AppColors.primary,
        ),
        (
          Icons.monitor_heart_outlined,
          'Active Today',
          '$activeToday',
          null,
          'last 24 hours',
          AppColors.purple,
        ),
        (
          Icons.person_add_alt_outlined,
          'New Users (Today)',
          '$newToday',
          null,
          'joined today',
          AppColors.accent,
        ),
        (
          Icons.workspace_premium_outlined,
          'Premium Users',
          '$premiumUsers',
          null,
          'subscribers',
          AppColors.warning,
        ),
        (
          Icons.calendar_month_outlined,
          'Avg. Cycle Length',
          '$avgCycle d',
          null,
          'user average',
          AppColors.info,
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
