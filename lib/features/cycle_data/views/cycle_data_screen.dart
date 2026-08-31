import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/cycle_data/controllers/cycle_data_controller.dart';
import 'package:joba_admin/features/cycle_data/views/widgets/cycle_age_distribution_card.dart';
import 'package:joba_admin/features/cycle_data/views/widgets/cycle_goals_card.dart';
import 'package:joba_admin/features/cycle_data/views/widgets/cycle_length_distribution_card.dart';
import 'package:joba_admin/features/cycle_data/views/widgets/cycle_privacy_banner.dart';
import 'package:joba_admin/features/cycle_data/views/widgets/cycle_stats_grid.dart';
import 'package:joba_admin/features/cycle_data/views/widgets/cycle_user_lookup_card.dart';

/// Cycle Data Screen - Aggregate metrics, distributions, and per-user lookup.
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
                const CycleStatsGrid(),
                const SizedBox(height: 12),
                const CyclePrivacyBanner(),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final bool isSuperAdmin = Get.isRegistered<AuthService>()
                        ? Get.find<AuthService>().canManageAdmins
                        : true;
                    if (Responsive.isDesktop(context)) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: isSuperAdmin ? 3 : 1,
                            child: const Column(
                              children: [
                                CycleLengthDistributionCard(),
                                SizedBox(height: 16),
                                CycleAgeDistributionCard(),
                                SizedBox(height: 16),
                                CycleGoalsCard(),
                              ],
                            ),
                          ),
                          if (isSuperAdmin) ...[
                            const SizedBox(width: 16),
                            const Expanded(flex: 2, child: CycleUserLookupCard()),
                          ],
                        ],
                      );
                    }
                    return Column(
                      children: [
                        const CycleLengthDistributionCard(),
                        const SizedBox(height: 16),
                        const CycleAgeDistributionCard(),
                        const SizedBox(height: 16),
                        const CycleGoalsCard(),
                        if (isSuperAdmin) ...[
                          const SizedBox(height: 16),
                          const CycleUserLookupCard(),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
