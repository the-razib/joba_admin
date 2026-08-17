import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/section_card.dart';

/// Card containing the donut chart breakdown of users by country.
class CountryDistributionCard extends StatelessWidget {
  const CountryDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Users by Country',
      child: DonutChart(
        centerValue: '24,789',
        slices: const [
          DonutSlice('Bangladesh', 78.4, AppColors.primary),
          DonutSlice('India', 10.7, AppColors.accent),
          DonutSlice('Pakistan', 4.3, AppColors.warning),
          DonutSlice('Indonesia', 2.8, AppColors.purple),
          DonutSlice('Others', 3.8, Color(0xFF9AA5A1)),
        ],
      ),
    );
  }
}
