import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/app_settings/controllers/settings_controller.dart';

/// Card containing general app settings such as maintenance mode, forced updates, AI chat, and audio features.
class GeneralSettingsCard extends GetView<SettingsController> {
  const GeneralSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final canEdit = controller.canEdit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General App Settings',
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Firestore app_config/general',
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.maintenanceMode.value,
                activeThumbColor: AppColors.danger,
                title: Text(
                  'Maintenance mode',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  'Blocks app access with a notice screen.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                onChanged: canEdit
                    ? (v) => controller.maintenanceMode.value = v
                    : null,
              ),
            ),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.forceUpdate.value,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Force update',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  'Users below the minimum version must update.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                onChanged: canEdit
                    ? (v) => controller.forceUpdate.value = v
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 4),
              child: TextField(
                controller: controller.minVersionController,
                enabled: canEdit,
                decoration: const InputDecoration(
                  labelText: 'Minimum app version',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.sathiAiEnabled.value,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Sathi AI chat enabled',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 13,
                  ),
                ),
                onChanged: canEdit
                    ? (v) => controller.sathiAiEnabled.value = v
                    : null,
              ),
            ),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.articleAudioEnabled.value,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Article audio playback (app)',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  'Enables the BN/EN audio player for articles.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                onChanged: canEdit
                    ? (v) => controller.articleAudioEnabled.value = v
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
