import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/cycle_data/controllers/cycle_data_controller.dart';
import 'package:joba_admin/features/users/views/user_detail_panel.dart';

class CycleDataScreen extends GetView<CycleDataController> {
  const CycleDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stats(context),
                const SizedBox(height: 12),
                _privacyNote(context),
                const SizedBox(height: 16),
                Responsive.isDesktop(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _chartsColumn(context)),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: _lookupCard(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _chartsColumn(context),
                          const SizedBox(height: 16),
                          _lookupCard(context),
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _stats(BuildContext context) {
    final goals = controller.goalCounts;
    final stats = [
      (Icons.sync_alt, 'Avg. Cycle Length', controller.avgCycle.toStringAsFixed(1), null, 'days across users', AppColors.primary),
      (Icons.water_drop_outlined, 'Avg. Period Duration', controller.avgPeriod.toStringAsFixed(1), null, 'days', AppColors.accent),
      (Icons.flag_outlined, 'Tracking', '${goals['track'] ?? 0}', null, 'users', AppColors.info),
      (Icons.child_care_outlined, 'Conceive / Avoid', '${(goals['conceive'] ?? 0) + (goals['avoid'] ?? 0)}', null, 'users', AppColors.purple),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.pick(context, mobile: 2, tablet: 4, desktop: 4),
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
  }

  Widget _privacyNote(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined,
                size: 17, color: AppColors.info),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cycle data is sensitive health information. Per-user views are restricted to Super Admins and recorded in Audit Logs. Default views are aggregate-only.',
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _chartsColumn(BuildContext context) {
    final buckets = controller.lengthBuckets;
    final max = buckets.map((b) => b.$2).fold<int>(1, (a, b) => a > b ? a : b);
    final ageBuckets = controller.ageBuckets;
    final ageMax = ageBuckets.map((b) => b.$2).fold<int>(1, (a, b) => a > b ? a : b);
    return Column(
      children: [
        SectionCard(
          title: 'Cycle Length Distribution',
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: max.toDouble() + 2,
                barGroups: [
                  for (var i = 0; i < buckets.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: buckets[i].$2.toDouble(),
                          color: AppColors.primary,
                          width: 34,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= buckets.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            buckets[i].$1,
                            style: TextStyle(
                              color: context.palette.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: context.palette.border, strokeWidth: 1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Age Distribution',
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: ageMax.toDouble() + 2,
                barGroups: [
                  for (var i = 0; i < ageBuckets.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: ageBuckets[i].$2.toDouble(),
                          color: AppColors.accent,
                          width: 34,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= ageBuckets.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            ageBuckets[i].$1,
                            style: TextStyle(
                              color: context.palette.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: context.palette.border, strokeWidth: 1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Cycle Goals',
          child: DonutChart(
            centerValue: '${controller.users.length}',
            centerLabel: 'Users',
            size: 160,
            slices: [
              DonutSlice('Track', (controller.goalCounts['track'] ?? 0).toDouble(), AppColors.primary),
              DonutSlice('Conceive', (controller.goalCounts['conceive'] ?? 0).toDouble(), AppColors.accent),
              DonutSlice('Avoid', (controller.goalCounts['avoid'] ?? 0).toDouble(), AppColors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lookupCard(BuildContext context) {
    return SectionCard(
      title: 'Per-User Lookup (Super Admin)',
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            onChanged: (_) => controller.searchTick.value++,
            decoration: const InputDecoration(
              hintText: 'Search user by name, email or UID...',
              isDense: true,
              prefixIcon: Icon(Icons.search, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            controller.searchTick.value;
            final list = controller.lookup;
            return Column(
              children: [
                for (final u in list)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => openUserDetail(context, u.uid),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      child: Row(
                        children: [
                          AvatarCircle(name: u.name, size: 38),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: TextStyle(
                                    color: context.palette.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${u.averageCycleLength}d cycle • ${u.averagePeriodDuration}d period • ${u.cycleGoal}',
                                  style: TextStyle(
                                    color: context.palette.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
