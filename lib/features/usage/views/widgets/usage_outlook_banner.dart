import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';

/// Headline summary banner of current cost trends and month-end forecast.
class UsageOutlookBanner extends GetView<UsageController> {
  const UsageOutlookBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final outlook = controller.outlook;
    final delta = controller.costDeltaPercent;
    final days = controller.rangeDays.value;

    final color = outlook.color;
    final icon = outlook.icon;
    final headline = outlook.headline;

    final detail = delta == null
        ? 'Not enough history to compare with the previous $days days.'
        : '${delta.abs().toStringAsFixed(1)}% '
            '${delta >= 0 ? 'higher' : 'lower'} than the previous $days days. '
            'Projected month-end total is '
            '${usd(controller.projectedMonthCost)}.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
