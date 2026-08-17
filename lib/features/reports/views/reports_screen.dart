import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
import 'package:joba_admin/features/reports/views/widgets/reports_stats_grid.dart';
import 'package:joba_admin/features/reports/views/widgets/reports_table_card.dart';

/// Reports Screen - Management dashboard for user bug reports, feedback, and feature requests.
class ReportsScreen extends GetView<ReportsController> {
  const ReportsScreen({super.key});

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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReportsStatsGrid(),
                SizedBox(height: 16),
                ReportsTableCard(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
