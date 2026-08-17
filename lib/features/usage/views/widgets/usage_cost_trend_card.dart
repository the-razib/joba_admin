import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';

/// Card showing daily spend activity line chart and period summary metrics.
class UsageCostTrendCard extends GetView<UsageController> {
  const UsageCostTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final w = controller.window;
      final costs = controller.dailyCosts;
      final step = (w.length / 6).ceil().clamp(1, 30);

      return SectionCard(
        title: 'Daily spend — last ${controller.rangeDays.value} days',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 22,
              runSpacing: 12,
              children: [
                _UsageMetric(
                  label: 'Period total',
                  value: usd(controller.windowCost),
                ),
                _UsageMetric(
                  label: 'Avg / day (7d)',
                  value: usd(controller.recentDailyAverage),
                ),
                _UsageMetric(
                  label: 'Month to date',
                  value: usd(controller.monthToDateCost),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ActivityLineChart(
              values: costs,
              labels: [
                for (var i = 0; i < w.length; i++)
                  i % step == 0 ? _fmtDate(w[i].date) : '',
              ],
              height: 240,
              color: AppColors.warning,
              axisFormatter: usd,
              tooltipFormatter: usd,
              minTop: 1,
              axisReservedSize: 48,
            ),
          ],
        ),
      );
    });
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _UsageMetric extends StatelessWidget {
  const _UsageMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.palette.textSecondary,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
