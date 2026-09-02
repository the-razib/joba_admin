import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/config_repository.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/utils/app_toast.dart';

class SathiAiController extends GetxController {
  final ConfigRepository configRepo = Get.find<ConfigRepository>();

  final enabled = true.obs;
  final visibleInMobile = true.obs;
  final allowGuestUsers = false.obs;
  final safetyFilter = true.obs;
  final budgetProtection = true.obs;
  final fallbackResponses = true.obs;
  final dailyUserLimit = 15.obs;
  final monthlyBudget = 150.0.obs;
  final selectedModel = 'gemini-2.5-flash-lite'.obs;
  final saving = false.obs;

  final dailyCalls = 18420.obs;
  final monthlyCalls = 482630.obs;
  final activeUsers = 12840.obs;
  final tokenUsage = 18.6.obs;
  final monthCost = 86.40.obs;

  final weeklyCalls = const [4.2, 5.1, 6.4, 6.0, 8.2, 7.6, 9.4].obs;
  final recentActivity = <SathiActivity>[
    SathiActivity(
      'Today, 10:42 AM',
      'Usage threshold updated',
      'Admin',
      'Policy',
    ),
    SathiActivity(
      'Today, 09:18 AM',
      '18,420 calls processed',
      'System',
      'Usage',
    ),
    SathiActivity(
      'Yesterday, 06:34 PM',
      'Safety filter enabled',
      'Md. Razib Hasan',
      'Security',
    ),
    SathiActivity(
      'Yesterday, 02:10 PM',
      'Model switched to Gemini 2.0 Flash',
      'Admin',
      'Config',
    ),
  ].obs;

  double get budgetPercent => monthlyBudget.value <= 0
      ? 0
      : (monthCost.value / monthlyBudget.value).clamp(0.0, 1.0);

  @override
  void onInit() {
    super.onInit();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final data = await configRepo.getDoc('sathi_ai');
      if (data == null) return;
      enabled.value = data['enabled'] as bool? ?? enabled.value;
      visibleInMobile.value =
          data['visibleInMobile'] as bool? ?? visibleInMobile.value;
      allowGuestUsers.value =
          data['allowGuestUsers'] as bool? ?? allowGuestUsers.value;
      safetyFilter.value =
          data['safetyFilterEnabled'] as bool? ?? safetyFilter.value;
      budgetProtection.value =
          data['budgetProtectionEnabled'] as bool? ?? budgetProtection.value;
      fallbackResponses.value =
          data['fallbackResponsesEnabled'] as bool? ?? fallbackResponses.value;
      dailyUserLimit.value =
          (data['dailyCallsPerUser'] as num?)?.toInt() ?? dailyUserLimit.value;
      monthlyBudget.value =
          (data['monthlyBudgetUsd'] as num?)?.toDouble() ?? monthlyBudget.value;
      selectedModel.value =
          data['defaultModel']?.toString() ?? selectedModel.value;
    } catch (_) {
      // Keep the safe local defaults when the config is unavailable.
    }
  }

  void setDailyLimit(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 0) dailyUserLimit.value = parsed;
  }

  void setBudget(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0) monthlyBudget.value = parsed;
  }

  Future<void> save() async {
    saving.value = true;
    try {
      await configRepo.saveDoc('sathi_ai', {
        'enabled': enabled.value,
        'visibleInMobile': visibleInMobile.value,
        'allowGuestUsers': allowGuestUsers.value,
        'safetyFilterEnabled': safetyFilter.value,
        'budgetProtectionEnabled': budgetProtection.value,
        'fallbackResponsesEnabled': fallbackResponses.value,
        'dailyCallsPerUser': dailyUserLimit.value,
        'monthlyBudgetUsd': monthlyBudget.value,
        'defaultModel': selectedModel.value,
        'maxOutputTokens': 450,
        'temperature': 0.4,
      });
      AppToast.success(
        'Sathi AI settings saved',
        'Mobile clients will apply the policy on their next config refresh.',
      );
    } catch (e) {
      AppToast.error('Save failed', 'Could not save Sathi AI settings: $e');
    } finally {
      saving.value = false;
    }
  }
}

class SathiActivity {
  const SathiActivity(this.time, this.event, this.actor, this.type);
  final String time;
  final String event;
  final String actor;
  final String type;

  Color get color => switch (type) {
    'Security' => AppColors.danger,
    'Usage' => AppColors.info,
    'Config' => AppColors.purple,
    _ => AppColors.primary,
  };
}
