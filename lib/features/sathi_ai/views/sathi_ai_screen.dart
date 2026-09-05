import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/sathi_ai/controllers/sathi_ai_controller.dart';

class SathiAiScreen extends GetView<SathiAiController> {
  const SathiAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(mobile ? 14 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Sathi AI Control',
                subtitle: 'Monitor usage, manage access, and protect AI spend',
                actions: [
                  Obx(
                    () => IconButton(
                      onPressed: controller.loadingUsage.value
                          ? null
                          : controller.loadUsageData,
                      icon: controller.loadingUsage.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 18),
                      tooltip: 'Refresh telemetry',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => ElevatedButton.icon(
                      onPressed: controller.saving.value
                          ? null
                          : controller.save,
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
              const SizedBox(height: 16),
              _statusBanner(context),
              const SizedBox(height: 16),
              _kpis(context),
              const SizedBox(height: 16),
              Responsive.isDesktop(context)
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _TrendCard()),
                        SizedBox(width: 16),
                        Expanded(flex: 2, child: _ModelCard()),
                      ],
                    )
                  : const Column(
                      children: [
                        _TrendCard(),
                        SizedBox(height: 16),
                        _ModelCard(),
                      ],
                    ),
              const SizedBox(height: 16),
              Responsive.isDesktop(context)
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _PolicyCard()),
                        SizedBox(width: 16),
                        Expanded(child: _SafetyCard()),
                      ],
                    )
                  : const Column(
                      children: [
                        _PolicyCard(),
                        SizedBox(height: 16),
                        _SafetyCard(),
                      ],
                    ),
              const SizedBox(height: 16),
              const _ActivityCard(),
              const SizedBox(height: 14),
              Obx(
                () => Text(
                  'Live Telemetry · Data syncs directly from sathi_ai_usage_daily. ${controller.faqMatchesMonth.value} queries answered free by offline FAQ layer.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBanner(BuildContext context) => Obx(
    () => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: .28)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sathi AI is live',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'The assistant is available to eligible mobile users. Current month spend is ${usd(controller.monthCost.value)} of ${usd(controller.monthlyBudget.value)} budget.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.enabled.value,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => controller.enabled.value = v,
          ),
        ],
      ),
    ),
  );

  Widget _kpis(BuildContext context) => Obx(
    () => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.pick(
        context,
        mobile: 2,
        tablet: 3,
        desktop: 5,
      ),
      mainAxisExtent: 104,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _kpi(
          'Active users',
          compactNumber(controller.activeUsers.value),
          'this month',
          Icons.people_alt_outlined,
          AppColors.primary,
        ),
        _kpi(
          'Total AI calls',
          compactNumber(controller.monthlyCalls.value),
          'this month',
          Icons.forum_outlined,
          AppColors.purple,
        ),
        _kpi(
          'Today\'s calls',
          compactNumber(controller.dailyCalls.value),
          'last 24 hours',
          Icons.bolt_outlined,
          AppColors.info,
        ),
        _kpi(
          'Tokens used',
          '${controller.tokenUsage.value}M',
          'input + output',
          Icons.data_usage_outlined,
          AppColors.accent,
        ),
        _kpi(
          'Estimated cost',
          usd(controller.monthCost.value),
          'this month',
          Icons.payments_outlined,
          AppColors.warning,
        ),
      ],
    ),
  );

  Widget _kpi(
    String label,
    String value,
    String note,
    IconData icon,
    Color color,
  ) {
    final palette = Get.context!.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(note, style: TextStyle(color: color, fontSize: 9.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends GetView<SathiAiController> {
  const _TrendCard();
  @override
  Widget build(BuildContext context) => Obx(
    () {
      final totalCalls = controller.weeklyCalls.fold<double>(0, (a, b) => a + b);
      final avgCalls = controller.weeklyCalls.isEmpty
          ? 0.0
          : totalCalls / controller.weeklyCalls.length;
      final peakCalls = controller.weeklyCalls.fold<double>(
        0,
        (a, b) => a > b ? a : b,
      );

      return SectionCard(
        title: 'AI calls — last 7 days',
        action: 'Last 7 days',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 26,
              children: [
                _Metric(
                  label: 'Total calls',
                  value: compactNumber(totalCalls),
                ),
                _Metric(
                  label: 'Daily average',
                  value: compactNumber(avgCalls),
                ),
                _Metric(
                  label: 'Peak day',
                  value: compactNumber(peakCalls),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ActivityLineChart(
              values: controller.weeklyCalls,
              labels: controller.weeklyLabels,
              height: 220,
              color: AppColors.purple,
              axisFormatter: compactNumber,
              tooltipFormatter: (v) => '${compactNumber(v)} calls',
              minTop: 10,
            ),
          ],
        ),
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(color: context.palette.textSecondary, fontSize: 11.5),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          color: context.palette.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
    ],
  );
}

class _ModelCard extends GetView<SathiAiController> {
  const _ModelCard();

  static String _formatModelTitle(String key) {
    if (key.contains('flash-lite') || key.contains('flash_lite')) {
      return 'Gemini 2.5 Flash-Lite';
    }
    if (key.contains('flash')) return 'Gemini 2.5 Flash';
    if (key.contains('pro')) return 'Gemini 2.5 Pro';
    return key;
  }

  static Color _colorForModel(String key) {
    if (key.contains('flash-lite') || key.contains('flash_lite')) {
      return AppColors.primary;
    }
    if (key.contains('flash')) return AppColors.purple;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) => SectionCard(
    title: 'Model usage mix',
    child: Obx(
      () => Column(
        children: [
          for (final entry in controller.modelMix.entries)
            _Bar(
              _formatModelTitle(entry.key),
              '${(entry.value * 100).toStringAsFixed(0)}%',
              entry.value,
              _colorForModel(entry.key),
            ),
          const SizedBox(height: 12),
          Text(
            'Zero-cost local FAQ deflects basic queries. Unmatched requests route through ${controller.selectedModel.value}.',
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar(this.label, this.value, this.fraction, this.color);
  final String label, value;
  final double fraction;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 12.5,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        LinearProgressIndicator(
          value: fraction,
          minHeight: 7,
          borderRadius: BorderRadius.circular(5),
          backgroundColor: context.palette.border,
          color: color,
        ),
      ],
    ),
  );
}

class _PolicyCard extends GetView<SathiAiController> {
  const _PolicyCard();
  @override
  Widget build(BuildContext context) => Obx(
    () => SectionCard(
      title: 'Access & usage policy',
      child: Column(
        children: [
          _SwitchRow(
            'Show Sathi AI in mobile app',
            'Controls whether the feature is visible to users.',
            controller.visibleInMobile.value,
            (v) => controller.visibleInMobile.value = v,
          ),
          _SwitchRow(
            'Allow guest users',
            'Require sign-in before starting a conversation.',
            controller.allowGuestUsers.value,
            (v) => controller.allowGuestUsers.value = v,
          ),
          const SizedBox(height: 8),
          _InputRow(
            label: 'Daily calls per user',
            value: '${controller.dailyUserLimit.value}',
            suffix: 'calls',
            onChanged: controller.setDailyLimit,
          ),
          _InputRow(
            label: 'Monthly budget alert',
            value: controller.monthlyBudget.value.toStringAsFixed(0),
            suffix: 'USD',
            onChanged: controller.setBudget,
          ),
        ],
      ),
    ),
  );
}

class _SafetyCard extends GetView<SathiAiController> {
  const _SafetyCard();
  @override
  Widget build(BuildContext context) => Obx(
    () => SectionCard(
      title: 'Safety & reliability',
      child: Column(
        children: [
          _SwitchRow(
            'Safety filter',
            'Block unsafe health advice and sensitive content.',
            controller.safetyFilter.value,
            (v) => controller.safetyFilter.value = v,
          ),
          _SwitchRow(
            'Budget protection',
            'Pause new calls when the monthly budget is reached.',
            controller.budgetProtection.value,
            (v) => controller.budgetProtection.value = v,
          ),
          _SwitchRow(
            'Fallback responses',
            'Show a helpful offline message when AI is unavailable.',
            controller.fallbackResponses.value,
            (v) => controller.fallbackResponses.value = v,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: controller.selectedModel.value,
            decoration: const InputDecoration(
              labelText: 'Default model',
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: 'gemini-2.5-flash-lite',
                child: Text('Gemini 2.5 Flash-Lite · Lowest cost (Recommended)'),
              ),
              DropdownMenuItem(
                value: 'gemini-2.5-flash',
                child: Text('Gemini 2.5 Flash · Higher quality'),
              ),
              DropdownMenuItem(
                value: 'gemini-3.1-flash-lite',
                child: Text('Gemini 3.1 Flash-Lite · Next-Gen'),
              ),
            ],
            onChanged: (v) {
              if (v != null) controller.selectedModel.value = v;
            },
          ),
        ],
      ),
    ),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(this.title, this.subtitle, this.value, this.onChanged);
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    value: value,
    activeThumbColor: AppColors.primary,
    title: Text(
      title,
      style: TextStyle(color: context.palette.textPrimary, fontSize: 13),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(color: context.palette.textSecondary, fontSize: 11.5),
    ),
    onChanged: onChanged,
  );
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.label,
    required this.value,
    required this.suffix,
    required this.onChanged,
  });
  final String label, value, suffix;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      initialValue: value,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
      ),
    ),
  );
}

class _ActivityCard extends GetView<SathiAiController> {
  const _ActivityCard();
  @override
  Widget build(BuildContext context) => Obx(
    () => SectionCard(
      title: 'Recent control activity',
      action: 'View audit logs',
      child: Column(
        children: [
          for (final item in controller.recentActivity)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(
                item.event,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${item.actor} · ${item.time}',
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 11,
                ),
              ),
              trailing: Text(
                item.type,
                style: TextStyle(
                  color: item.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
