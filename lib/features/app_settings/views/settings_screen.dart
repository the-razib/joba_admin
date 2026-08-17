import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/app_settings/controllers/settings_controller.dart';
import 'package:joba_admin/features/app_settings/views/widgets/algorithm_config_card.dart';
import 'package:joba_admin/features/app_settings/views/widgets/general_settings_card.dart';
import 'package:joba_admin/features/app_settings/views/widgets/settings_read_only_banner.dart';

/// App Settings Screen - Live configuration for the Joba mobile app algorithms and features.
class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'App Settings',
                subtitle: 'Live configuration for the Joba app',
                actions: [
                  Obx(
                    () => ElevatedButton.icon(
                      onPressed: (controller.canEdit && !controller.saving.value)
                          ? () => controller.saveForm()
                          : null,
                      icon: controller.saving.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
              Obx(() {
                if (controller.canEdit) return const SizedBox();
                return const Column(
                  children: [
                    SizedBox(height: 12),
                    SettingsReadOnlyBanner(),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Responsive.isDesktop(context)
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: AlgorithmConfigCard()),
                        SizedBox(width: 16),
                        Expanded(child: GeneralSettingsCard()),
                      ],
                    )
                  : const Column(
                      children: [
                        AlgorithmConfigCard(),
                        SizedBox(height: 16),
                        GeneralSettingsCard(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
