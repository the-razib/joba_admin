import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';

/// Card containing the user activity line chart with time range selector dropdown.
class UserActivityChartCard extends GetView<DashboardController> {
  const UserActivityChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'User Activity Overview',
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Obx(
                    () => PopupMenuButton<String>(
                      onSelected: controller.setRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.palette.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.range.value,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.textPrimary,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ),
                      itemBuilder: (_) => [
                        for (final r in [
                          'Last 7 Days',
                          'Last 30 Days',
                          'Last 90 Days',
                        ])
                          PopupMenuItem(value: r, child: Text(r)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ActivityLineChart(
                values: controller.activityValues,
                labels: controller.activityLabels,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
