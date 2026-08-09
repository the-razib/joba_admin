import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/admin_user.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/app_settings/controllers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController controller = Get.find();

  late final TextEditingController _version =
      TextEditingController(text: controller.algorithmVersion.value);
  late final TextEditingController _confidence =
      TextEditingController(text: '${controller.confidenceThreshold.value}');
  late final List<TextEditingController> _weights = [
    for (final w in controller.wmaWeights) TextEditingController(text: '$w'),
  ];
  late final TextEditingController _outlier =
      TextEditingController(text: '${controller.outlierWeightFactor.value}');
  late final TextEditingController _variance = TextEditingController(
      text: '${controller.irregularVarianceThreshold.value}');
  late final TextEditingController _minVersion =
      TextEditingController(text: controller.minAppVersion.value);

  bool get _canEdit =>
      Get.find<AuthService>().user.value?.role == AdminRole.superAdmin;

  @override
  void dispose() {
    _version.dispose();
    _confidence.dispose();
    for (final w in _weights) {
      w.dispose();
    }
    _outlier.dispose();
    _variance.dispose();
    _minVersion.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c, double fallback) =>
      double.tryParse(c.text) ?? fallback;

  Future<void> _save() async {
    controller.algorithmVersion.value = _version.text.trim();
    controller.confidenceThreshold.value =
        _parse(_confidence, controller.confidenceThreshold.value);
    controller.wmaWeights.value = [
      for (var i = 0; i < 5; i++)
        _parse(_weights[i], controller.wmaWeights[i]),
    ];
    controller.outlierWeightFactor.value =
        _parse(_outlier, controller.outlierWeightFactor.value);
    controller.irregularVarianceThreshold.value =
        _parse(_variance, controller.irregularVarianceThreshold.value);
    controller.minAppVersion.value = _minVersion.text.trim();
    await controller.save();
  }

  @override
  Widget build(BuildContext context) {
    final algorithm = _card(
      context,
      'Algorithm Configuration',
      'Firestore app_config/algorithm — read by the app on launch',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row2([
            _field('Algorithm version', _version),
            _field('Confidence threshold', _confidence),
          ]),
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
              for (final w in _weights)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextField(
                      controller: w,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _row2([
            _field('Outlier weight factor', _outlier),
            _field('Irregular variance threshold', _variance),
          ]),
          const SizedBox(height: 8),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.showIrregularWarning.value,
              activeThumbColor: AppColors.primary,
              title: Text('Show irregular cycle warning',
                  style: TextStyle(
                      color: context.palette.textPrimary, fontSize: 13)),
              onChanged: _canEdit
                  ? (v) => controller.showIrregularWarning.value = v
                  : null,
            ),
          ),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.enableMedianFallback.value,
              activeThumbColor: AppColors.primary,
              title: Text('Median fallback on high variance',
                  style: TextStyle(
                      color: context.palette.textPrimary, fontSize: 13)),
              onChanged: _canEdit
                  ? (v) => controller.enableMedianFallback.value = v
                  : null,
            ),
          ),
        ],
      ),
    );

    final general = _card(
      context,
      'General App Settings',
      'Firestore app_config/general',
      Column(
        children: [
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.maintenanceMode.value,
              activeThumbColor: AppColors.danger,
              title: Text('Maintenance mode',
                  style: TextStyle(
                      color: context.palette.textPrimary, fontSize: 13)),
              subtitle: Text('Blocks app access with a notice screen.',
                  style: TextStyle(
                      color: context.palette.textSecondary, fontSize: 11.5)),
              onChanged: _canEdit
                  ? (v) => controller.maintenanceMode.value = v
                  : null,
            ),
          ),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.forceUpdate.value,
              activeThumbColor: AppColors.primary,
              title: Text('Force update',
                  style: TextStyle(
                      color: context.palette.textPrimary, fontSize: 13)),
              subtitle: Text('Users below the minimum version must update.',
                  style: TextStyle(
                      color: context.palette.textSecondary, fontSize: 11.5)),
              onChanged: _canEdit
                  ? (v) => controller.forceUpdate.value = v
                  : null,
            ),
          ),
          _field('Minimum app version', _minVersion),
          const SizedBox(height: 4),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.sathiAiEnabled.value,
              activeThumbColor: AppColors.primary,
              title: Text('Sathi AI chat enabled',
                  style: TextStyle(
                      color: context.palette.textPrimary, fontSize: 13)),
              onChanged: _canEdit
                  ? (v) => controller.sathiAiEnabled.value = v
                  : null,
            ),
          ),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.articleAudioEnabled.value,
              activeThumbColor: AppColors.primary,
              title: Text('Article audio playback (app)',
                  style: TextStyle(
                      color: context.palette.textPrimary, fontSize: 13)),
              subtitle: Text('Enables the BN/EN audio player for articles.',
                  style: TextStyle(
                      color: context.palette.textSecondary, fontSize: 11.5)),
              onChanged: _canEdit
                  ? (v) => controller.articleAudioEnabled.value = v
                  : null,
            ),
          ),
        ],
      ),
    );

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
                      onPressed:
                          (_canEdit && !controller.saving.value)
                              ? _save
                              : null,
                      icon: controller.saving.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
              if (!_canEdit) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_outlined,
                          size: 17, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Read-only: only Super Admins can change app settings.',
                          style: TextStyle(
                            color: context.palette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Responsive.isDesktop(context)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: algorithm),
                        const SizedBox(width: 16),
                        Expanded(child: general),
                      ],
                    )
                  : Column(
                      children: [
                        algorithm,
                        const SizedBox(height: 16),
                        general,
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row2(List<Widget> children) => Row(
        children: [
          for (final c in children) Expanded(child: c),
        ],
      );

  Widget _field(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(right: 12, bottom: 4),
        child: TextField(
          controller: c,
          enabled: _canEdit,
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );

  Widget _card(BuildContext context, String title, String subtitle,
          Widget child) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      );
}
