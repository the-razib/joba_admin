import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/core/services/auth_service.dart';

/// Mirrors the app's `DynamicConfig` (app_config/algorithm) plus general
/// app-level settings. Phase 3 writes straight to Firestore app_config.
class SettingsController extends GetxController {
  // app_config/algorithm (mirrors DynamicConfig)
  final algorithmVersion = '1.0.0'.obs;
  final confidenceThreshold = 0.3.obs;
  final wmaWeights = [0.35, 0.25, 0.20, 0.12, 0.08].obs;
  final outlierWeightFactor = 0.3.obs;
  final irregularVarianceThreshold = 5.0.obs;
  final showIrregularWarning = true.obs;
  final enableMedianFallback = true.obs;

  // app_config/general
  final maintenanceMode = false.obs;
  final forceUpdate = false.obs;
  final minAppVersion = '1.0.0'.obs;
  final sathiAiEnabled = true.obs;
  final articleAudioEnabled = false.obs;

  final saving = false.obs;

  bool get canEdit =>
      Get.find<AuthService>().user.value?.role == AdminRole.superAdmin;

  late final TextEditingController versionController;
  late final TextEditingController confidenceController;
  late final List<TextEditingController> weightsControllers;
  late final TextEditingController outlierController;
  late final TextEditingController varianceController;
  late final TextEditingController minVersionController;

  @override
  void onInit() {
    super.onInit();
    versionController = TextEditingController(text: algorithmVersion.value);
    confidenceController =
        TextEditingController(text: '${confidenceThreshold.value}');
    weightsControllers = [
      for (final w in wmaWeights) TextEditingController(text: '$w'),
    ];
    outlierController =
        TextEditingController(text: '${outlierWeightFactor.value}');
    varianceController =
        TextEditingController(text: '${irregularVarianceThreshold.value}');
    minVersionController = TextEditingController(text: minAppVersion.value);
  }

  @override
  void onClose() {
    versionController.dispose();
    confidenceController.dispose();
    for (final w in weightsControllers) {
      w.dispose();
    }
    outlierController.dispose();
    varianceController.dispose();
    minVersionController.dispose();
    super.onClose();
  }

  double _parse(TextEditingController c, double fallback) =>
      double.tryParse(c.text) ?? fallback;

  Future<void> saveForm() async {
    algorithmVersion.value = versionController.text.trim();
    confidenceThreshold.value =
        _parse(confidenceController, confidenceThreshold.value);
    wmaWeights.value = [
      for (var i = 0; i < 5; i++)
        _parse(weightsControllers[i], wmaWeights[i]),
    ];
    outlierWeightFactor.value =
        _parse(outlierController, outlierWeightFactor.value);
    irregularVarianceThreshold.value =
        _parse(varianceController, irregularVarianceThreshold.value);
    minAppVersion.value = minVersionController.text.trim();
    await save();
  }

  Future<void> save() async {
    saving.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    saving.value = false;
    Get.snackbar(
      'Settings saved',
      'The app picks these up on next launch via app_config (mock).',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
