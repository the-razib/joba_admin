import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';

/// Card containing the donut chart breakdown of users by country.
class CountryDistributionCard extends GetView<DashboardController> {
  const CountryDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Users by Country',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final donut = DonutChart(
                centerValue: controller.totalUsersFormatted,
                slices: controller.countryDonutSlices,
              );
              if (isDesktop) {
                return SizedBox(
                  height: 260,
                  child: Center(child: donut),
                );
              }
              return donut;
            }),
          ],
        ),
      ),
    );
  }
}
