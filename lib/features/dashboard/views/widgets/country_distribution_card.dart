import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/charts.dart';

/// Card containing the donut chart breakdown of users by country.
class CountryDistributionCard extends StatelessWidget {
  const CountryDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    const donut = DonutChart(
      centerValue: '24,789',
      slices: [
        DonutSlice('Bangladesh', 78.4, AppColors.primary),
        DonutSlice('India', 10.7, AppColors.accent),
        DonutSlice('Pakistan', 4.3, AppColors.warning),
        DonutSlice('Indonesia', 2.8, AppColors.purple),
        DonutSlice('Others', 3.8, Color(0xFF9AA5A1)),
      ],
    );

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
            if (isDesktop)
              const SizedBox(
                height: 260,
                child: Center(child: donut),
              )
            else
              donut,
          ],
        ),
      ),
    );
  }
}

