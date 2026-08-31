import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/config_repository.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/core/services/auth_service.dart';

/// Mirrors the app's `DynamicConfig` (app_config/algorithm) plus general
/// app-level settings (app_config/general).
class SettingsController extends GetxController {
  final ConfigRepository configRepo = Get.find();

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

  final loading = true.obs;
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
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    try {
      final general = await configRepo.getDoc('general');
      if (general != null) {
        maintenanceMode.value = general['maintenanceMode'] as bool? ?? false;
        forceUpdate.value = general['forceUpdate'] as bool? ?? false;
        minAppVersion.value =
            general['minSupportedVersion']?.toString() ?? '1.0.0';
        minVersionController.text = minAppVersion.value;
        sathiAiEnabled.value = general['sathiAiEnabled'] as bool? ?? true;
        articleAudioEnabled.value =
            general['articleAudioEnabled'] as bool? ?? false;
      }

      final algo = await configRepo.getDoc('algorithm');
      if (algo != null) {
        algorithmVersion.value = algo['version']?.toString() ?? '1.0.0';
        versionController.text = algorithmVersion.value;

        confidenceThreshold.value =
            (algo['confidenceThreshold'] as num?)?.toDouble() ?? 0.3;
        confidenceController.text = '${confidenceThreshold.value}';

        if (algo['wmaWeights'] is List) {
          final list = (algo['wmaWeights'] as List)
              .map((w) => (w as num).toDouble())
              .toList();
          if (list.length == 5) {
            wmaWeights.value = list;
            for (var i = 0; i < 5; i++) {
              weightsControllers[i].text = '${list[i]}';
            }
          }
        }

        outlierWeightFactor.value =
            (algo['outlierWeightFactor'] as num?)?.toDouble() ?? 0.3;
        outlierController.text = '${outlierWeightFactor.value}';

        irregularVarianceThreshold.value =
            (algo['irregularVarianceThreshold'] as num?)?.toDouble() ?? 5.0;
        varianceController.text = '${irregularVarianceThreshold.value}';

        showIrregularWarning.value =
            algo['showIrregularWarning'] as bool? ?? true;
        enableMedianFallback.value =
            algo['enableMedianFallback'] as bool? ?? true;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      loading.value = false;
    }
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
    final conf = _parse(confidenceController, confidenceThreshold.value);
    if (conf < 0.0 || conf > 1.0) {
      AppToast.error('Validation Error', 'Confidence threshold must be between 0.0 and 1.0');
      return;
    }

    final parsedWeights = [
      for (var i = 0; i < 5; i++)
        _parse(weightsControllers[i], wmaWeights[i]),
    ];
    final sum = parsedWeights.fold<double>(0.0, (a, b) => a + b);
    if ((sum - 1.0).abs() > 0.08) {
      AppToast.error('Validation Error', 'WMA weights should sum to 1.0 (current sum: ${sum.toStringAsFixed(2)})');
      return;
    }

    algorithmVersion.value = versionController.text.trim();
    confidenceThreshold.value = conf;
    wmaWeights.value = parsedWeights;
    outlierWeightFactor.value =
        _parse(outlierController, outlierWeightFactor.value);
    irregularVarianceThreshold.value =
        _parse(varianceController, irregularVarianceThreshold.value);
    minAppVersion.value = minVersionController.text.trim();
    await save();
  }

  Future<void> save() async {
    saving.value = true;
    try {
      await configRepo.saveDoc('general', {
        'maintenanceMode': maintenanceMode.value,
        'forceUpdate': forceUpdate.value,
        'minSupportedVersion': minAppVersion.value,
        'sathiAiEnabled': sathiAiEnabled.value,
        'articleAudioEnabled': articleAudioEnabled.value,
      });

      await configRepo.saveDoc('algorithm', {
        'version': algorithmVersion.value,
        'confidenceThreshold': confidenceThreshold.value,
        'wmaWeights': wmaWeights.toList(),
        'outlierWeightFactor': outlierWeightFactor.value,
        'irregularVarianceThreshold': irregularVarianceThreshold.value,
        'showIrregularWarning': showIrregularWarning.value,
        'enableMedianFallback': enableMedianFallback.value,
      });

      AppToast.success(
        'Settings saved',
        'Mobile app picks these up via app_config documents.',
      );
    } catch (e) {
      AppToast.error('Save failed', 'Could not save app settings: $e');
    } finally {
      saving.value = false;
    }
  }
}
