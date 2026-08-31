import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';
import 'package:joba_admin/features/reminders/views/widgets/reminders_header_actions.dart';
import 'package:joba_admin/features/reminders/views/widgets/reminders_order_card.dart';
import 'package:joba_admin/features/reminders/views/widgets/reminders_preview_card.dart';
import 'package:joba_admin/features/reminders/views/widgets/reminders_scope_banner.dart';
import 'package:joba_admin/features/reminders/views/widgets/reminders_stats_grid.dart';
import 'package:joba_admin/features/reminders/views/widgets/reminders_usage_card.dart';

/// Reminders Screen - Global planning and reordering dashboard for reminders.
class RemindersScreen extends GetView<RemindersController> {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final isDesktop = Responsive.isDesktop(context);
      final bool canManage = Get.isRegistered<AuthService>()
          ? Get.find<AuthService>().canManageContent
          : true;

      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Reminder Tracker',
                  subtitle:
                      'Control the order every user sees their pad, '
                      'period preparation and medicine reminders in.',
                  actions: canManage ? const [RemindersHeaderActions()] : const [],
                ),
                const SizedBox(height: 16),
                const RemindersStatsGrid(),
                const SizedBox(height: 12),
                const RemindersScopeBanner(),
                const SizedBox(height: 16),
                if (isDesktop)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: RemindersOrderCard()),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            RemindersPreviewCard(),
                            SizedBox(height: 16),
                            RemindersUsageCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const Column(
                    children: [
                      RemindersOrderCard(),
                      SizedBox(height: 16),
                      RemindersPreviewCard(),
                      SizedBox(height: 16),
                      RemindersUsageCard(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
