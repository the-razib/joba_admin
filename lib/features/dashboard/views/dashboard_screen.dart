import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:joba_admin/features/dashboard/views/widgets/country_distribution_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_popular_articles_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_push_banner.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_recent_reports_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_recent_users_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_stats_grid.dart';
import 'package:joba_admin/features/dashboard/views/widgets/user_activity_chart_card.dart';

/// Dashboard Screen - Main high-level overview metrics, activity trends, demographics, and quick feeds.
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

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
              children: [
                const DashboardStatsGrid(),
                const SizedBox(height: 16),
                Responsive.isDesktop(context)
                    ? const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: UserActivityChartCard()),
                          SizedBox(width: 16),
                          Expanded(flex: 2, child: CountryDistributionCard()),
                        ],
                      )
                    : const Column(
                        children: [
                          UserActivityChartCard(),
                          SizedBox(height: 16),
                          CountryDistributionCard(),
                        ],
                      ),
                const SizedBox(height: 16),
                Responsive.isDesktop(context)
                    ? const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: DashboardRecentUsersCard()),
                          SizedBox(width: 16),
                          Expanded(child: DashboardPopularArticlesCard()),
                          SizedBox(width: 16),
                          Expanded(child: DashboardRecentReportsCard()),
                        ],
                      )
                    : const Column(
                        children: [
                          DashboardRecentUsersCard(),
                          SizedBox(height: 16),
                          DashboardPopularArticlesCard(),
                          SizedBox(height: 16),
                          DashboardRecentReportsCard(),
                        ],
                      ),
                const SizedBox(height: 16),
                const DashboardPushBanner(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
