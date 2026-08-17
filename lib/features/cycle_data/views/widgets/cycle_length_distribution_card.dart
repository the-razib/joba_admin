import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/cycle_data/controllers/cycle_data_controller.dart';

/// Card displaying the bar chart distribution of user cycle lengths.
class CycleLengthDistributionCard extends GetView<CycleDataController> {
  const CycleLengthDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Cycle Length Distribution',
      child: Obx(() {
        final buckets = controller.lengthBuckets;
        final max = buckets.map((b) => b.$2).fold<int>(1, (a, b) => a > b ? a : b);

        return SizedBox(
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
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
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
        );
      }),
    );
  }
}
