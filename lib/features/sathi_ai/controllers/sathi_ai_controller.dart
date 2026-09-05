import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:joba_admin/core/repositories/config_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';

class SathiAiController extends GetxController {
  final ConfigRepository configRepo = Get.find<ConfigRepository>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Policy Observables
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

  // Live Telemetry Observables
  final loadingUsage = false.obs;
  final dailyCalls = 0.obs;
  final monthlyCalls = 0.obs;
  final activeUsers = 0.obs;
  final tokenUsage = 0.0.obs; // In Millions (e.g. 0.45M)
  final monthCost = 0.0.obs; // In USD
  final faqMatchesMonth = 0.obs;

  // Last 7 Days Trend
  final weeklyCalls = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  final weeklyLabels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].obs;

  // Model Mix Distribution
  final modelMix = <String, double>{
    'gemini-2.5-flash-lite': 1.0,
  }.obs;

  // Recent Control Activities
  final recentActivity = <SathiActivity>[].obs;

  double get budgetPercent => monthlyBudget.value <= 0
      ? 0
      : (monthCost.value / monthlyBudget.value).clamp(0.0, 1.0);

  @override
  void onInit() {
    super.onInit();
    _loadConfig();
    loadUsageData();
  }

  Future<void> _loadConfig() async {
    AppLoggerHelper.info('[SathiAiController] 🤖 Loading Sathi AI policy config...');
    try {
      final data = await configRepo.getDoc('sathi_ai');
      if (data == null) {
        AppLoggerHelper.info('[SathiAiController] No remote sathi_ai config found, using local defaults');
        return;
      }
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

      AppLoggerHelper.success('SathiAiController', 'Loaded Sathi AI config (model: ${selectedModel.value}, enabled: ${enabled.value})');
    } catch (e, st) {
      AppLoggerHelper.failure('SathiAiController', 'Failed to load Sathi AI config: $e', error: e, stackTrace: st);
    }
  }

  Future<void> loadUsageData() async {
    loadingUsage.value = true;
    AppLoggerHelper.info('[SathiAiController] 📊 Loading Sathi AI live usage telemetry...');
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final monthPrefix = DateFormat('yyyy-MM').format(now);

      // 1. Fetch last 30 daily usage rollups from sathi_ai_usage_daily
      final snap = await _firestore
          .collection('sathi_ai_usage_daily')
          .orderBy('date', descending: true)
          .limit(30)
          .get();

      int mCalls = 0;
      int dCalls = 0;
      int mTokens = 0;
      double mCost = 0.0;
      int mFaq = 0;
      final modelCounts = <String, int>{};
      final dailyMap = <String, Map<String, dynamic>>{};

      for (final doc in snap.docs) {
        final data = doc.data();
        final date = data['date']?.toString() ?? doc.id;
        dailyMap[date] = data;

        final calls = (data['calls'] as num?)?.toInt() ?? 0;
        final totalTokens = (data['totalTokens'] as num?)?.toInt() ?? 0;
        final cost = (data['costUsd'] as num?)?.toDouble() ?? 0.0;
        final faq = (data['faqMatches'] as num?)?.toInt() ?? 0;

        if (date == todayStr) {
          dCalls = calls;
        }

        if (date.startsWith(monthPrefix)) {
          mCalls += calls;
          mTokens += totalTokens;
          mCost += cost;
          mFaq += faq;

          if (data['modelBreakdown'] is Map) {
            final breakdown = data['modelBreakdown'] as Map<String, dynamic>;
            breakdown.forEach((model, usageCount) {
              final c = (usageCount as num?)?.toInt() ?? 0;
              final cleanModel = model.replaceAll('_', '.');
              modelCounts[cleanModel] = (modelCounts[cleanModel] ?? 0) + c;
            });
          }
        }
      }

      dailyCalls.value = dCalls;
      monthlyCalls.value = mCalls;
      tokenUsage.value = double.parse((mTokens / 1000000.0).toStringAsFixed(2));
      monthCost.value = double.parse(mCost.toStringAsFixed(2));
      faqMatchesMonth.value = mFaq;

      // 2. Build last 7 days chart
      final chartCalls = <double>[];
      final chartLabels = <String>[];

      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayStr = DateFormat('yyyy-MM-dd').format(day);
        final label = DateFormat('E').format(day);

        chartLabels.add(label);
        final dayData = dailyMap[dayStr];
        final calls = (dayData?['calls'] as num?)?.toDouble() ?? 0.0;
        chartCalls.add(calls);
      }

      weeklyCalls.assignAll(chartCalls);
      weeklyLabels.assignAll(chartLabels);

      // 3. Compute Model Mix
      final totalModelInvocations =
          modelCounts.values.fold<int>(0, (a, b) => a + b);
      if (totalModelInvocations > 0) {
        final mix = <String, double>{};
        modelCounts.forEach((model, usageCount) {
          mix[model] = usageCount / totalModelInvocations;
        });
        modelMix.assignAll(mix);
      } else {
        modelMix.assignAll({selectedModel.value: 1.0});
      }

      // 4. Fetch Active Users count
      try {
        final userSnap =
            await _firestore.collection('sathi_ai_user_usage').count().get();
        activeUsers.value = userSnap.count ?? 0;
      } catch (_) {
        activeUsers.value = dCalls > 0 ? (dCalls * 0.8).ceil() : 0;
      }

      // 5. Fetch recent audit activity
      await _loadAuditActivity();
      AppLoggerHelper.success(
        'SathiAiController',
        'Telemetry loaded: $dCalls daily calls, $mCalls monthly calls, \$${monthCost.value} cost',
      );
    } catch (e, st) {
      AppLoggerHelper.failure('SathiAiController', 'Failed to load Sathi AI usage telemetry: $e', error: e, stackTrace: st);
    } finally {
      loadingUsage.value = false;
    }
  }

  Future<void> _loadAuditActivity() async {
    try {
      final snap = await _firestore
          .collection('audit_logs')
          .where('module', isEqualTo: 'Sathi AI')
          .orderBy('time', descending: true)
          .limit(5)
          .get();

      if (snap.docs.isNotEmpty) {
        final list = snap.docs.map((doc) {
          final data = doc.data();
          final time = data['time'] is Timestamp
              ? (data['time'] as Timestamp).toDate()
              : DateTime.tryParse(data['time']?.toString() ?? '') ??
                  DateTime.now();
          final formattedTime = _formatRelativeTime(time);
          final details =
              data['details']?.toString() ?? 'Sathi AI policy updated';
          final adminName = data['adminName']?.toString() ?? 'Admin';
          final action = data['action']?.toString() ?? 'Config';

          return SathiActivity(formattedTime, details, adminName, action);
        }).toList();
        recentActivity.assignAll(list);
      } else {
        recentActivity.assignAll([
          const SathiActivity(
            'Just now',
            'Sathi AI telemetry active',
            'System',
            'Usage',
          ),
        ]);
      }
    } catch (_) {}
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d, h:mm a').format(time);
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
    AppLoggerHelper.info('[SathiAiController] 💾 Saving Sathi AI policy to app_config/sathi_ai...');
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

      await AuditService.log(
        module: 'Sathi AI',
        action: AuditAction.updated,
        details:
            'Policy saved: model=${selectedModel.value}, dailyLimit=${dailyUserLimit.value}, budget=\$${monthlyBudget.value.toStringAsFixed(0)}',
      );

      await _loadAuditActivity();
      AppLoggerHelper.success('SathiAiController', 'Sathi AI policy saved successfully');

      AppToast.success(
        'Sathi AI settings saved',
        'Mobile clients will apply the policy on their next config refresh.',
      );
    } catch (e, st) {
      AppLoggerHelper.failure('SathiAiController', 'Could not save Sathi AI settings: $e', error: e, stackTrace: st);
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

