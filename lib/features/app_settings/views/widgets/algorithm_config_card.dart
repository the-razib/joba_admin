import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/app_settings/controllers/settings_controller.dart';

/// Card containing algorithm configuration fields, WMA cycle weights, and fallback switches.
class AlgorithmConfigCard extends GetView<SettingsController> {
  const AlgorithmConfigCard({super.key});

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
              'Algorithm Configuration',
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Firestore app_config/algorithm — read by the app on launch',
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 4),
                    child: TextField(
                      controller: controller.versionController,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: 'Algorithm version',
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 4),
                    child: TextField(
                      controller: controller.confidenceController,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: 'Confidence threshold',
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'WMA weights (last 5 cycles)',
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final w in controller.weightsControllers)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextField(
                        controller: w,
                        enabled: canEdit,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 4),
                    child: TextField(
                      controller: controller.outlierController,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: 'Outlier weight factor',
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 4),
                    child: TextField(
                      controller: controller.varianceController,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: 'Irregular variance threshold',
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.showIrregularWarning.value,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Show irregular cycle warning',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 13,
                  ),
                ),
                onChanged: canEdit
                    ? (v) => controller.showIrregularWarning.value = v
                    : null,
              ),
            ),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.enableMedianFallback.value,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Median fallback on high variance',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 13,
                  ),
                ),
                onChanged: canEdit
                    ? (v) => controller.enableMedianFallback.value = v
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
