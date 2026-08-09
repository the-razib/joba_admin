import 'package:get/get.dart';

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
