import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';

/// Responsive grid of 5 KPI statistics for the User Directory.
class UsersStatsGrid extends StatelessWidget {
  const UsersStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const stats = [
      (
        Icons.group_outlined,
        'Total Users',
        '24,789',
        12.5,
        'vs last 7 days',
        AppColors.primary,
      ),
      (
        Icons.monitor_heart_outlined,
        'Active Today',
        '4,278',
        8.3,
        'vs yesterday',
        AppColors.purple,
      ),
      (
        Icons.person_add_alt_outlined,
        'New Users (Today)',
        '689',
        15.2,
        'vs yesterday',
        AppColors.accent,
      ),
      (
        Icons.workspace_premium_outlined,
        'Premium Users',
        '2,356',
        10.1,
        'vs last 7 days',
        AppColors.warning,
      ),
      (
        Icons.calendar_month_outlined,
        'Avg. Cycle Length',
        '28.7',
        -1.3,
        'vs last 30 days',
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
  }
}
