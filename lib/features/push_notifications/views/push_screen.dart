import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_campaign_table.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_channel_filter.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_composer.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_stats_grid.dart';

/// Push Notifications Screen - Management dashboard for push and in-app campaigns.
class PushScreen extends GetView<PushController> {
  const PushScreen({super.key});

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
                PageHeader(
                  title: 'Push Notifications',
                  subtitle:
                      'Push and in-app dialogs, composed in বাংলা and '
                      'English',
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () => showPushComposer(context),
                      icon: const Icon(Icons.add, size: 17),
                      label: mobile
                          ? const SizedBox()
                          : const Text('New Notification'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const PushStatsGrid(),
                const SizedBox(height: 16),
                const PushChannelFilter(),
                const SizedBox(height: 12),
                const PushCampaignTable(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
