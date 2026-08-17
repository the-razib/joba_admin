import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';
import 'package:joba_admin/features/usage/views/widgets/usage_cost_trend_card.dart';
import 'package:joba_admin/features/usage/views/widgets/usage_kpi_grid.dart';
import 'package:joba_admin/features/usage/views/widgets/usage_outlook_banner.dart';
import 'package:joba_admin/features/usage/views/widgets/usage_quota_card.dart';
import 'package:joba_admin/features/usage/views/widgets/usage_range_picker.dart';
import 'package:joba_admin/features/usage/views/widgets/usage_service_breakdown_card.dart';
import 'package:joba_admin/features/usage/views/widgets/usage_source_note.dart';

/// Usage & Cost Screen - Firebase consumption metrics and projected spend.
class UsageScreen extends GetView<UsageController> {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(mobile ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Usage & Cost',
                  subtitle: 'Firebase consumption and projected spend',
                  actions: [UsageRangePicker()],
                ),
                const SizedBox(height: 16),
                const UsageOutlookBanner(),
                const SizedBox(height: 16),
                const UsageKpiGrid(),
                const SizedBox(height: 16),
                const UsageCostTrendCard(),
                const SizedBox(height: 16),
                if (mobile) ...[
                  const UsageQuotaCard(),
                  const SizedBox(height: 16),
                  const UsageServiceBreakdownCard(),
                ] else
                  const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: UsageQuotaCard()),
                        SizedBox(width: 16),
                        Expanded(flex: 2, child: UsageServiceBreakdownCard()),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                const UsageSourceNote(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
