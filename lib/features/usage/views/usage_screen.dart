import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/usage_metrics.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';

class UsageScreen extends GetView<UsageController> {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(mobile ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Usage & Cost',
                  subtitle: 'Firebase consumption and projected spend',
                  actions: [_RangePicker(controller: controller)],
                ),
                const SizedBox(height: 16),
                const _OutlookBanner(),
                const SizedBox(height: 16),
                const _KpiGrid(),
                const SizedBox(height: 16),
                const _CostTrendCard(),
                const SizedBox(height: 16),
                if (mobile) ...[
                  const _QuotaCard(),
                  const SizedBox(height: 16),
                  const _ServiceBreakdownCard(),
                ] else
                  const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: _QuotaCard()),
                        SizedBox(width: 16),
                        Expanded(flex: 2, child: _ServiceBreakdownCard()),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                const _SourceNote(),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _RangePicker extends StatelessWidget {
  const _RangePicker({required this.controller});

  final UsageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SegmentedButton<int>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: [
          for (final d in UsageController.ranges)
            ButtonSegment(value: d, label: Text('${d}d')),
        ],
        selected: {controller.rangeDays.value},
        onSelectionChanged: (s) => controller.setRange(s.first),
      ),
    );
  }
}

/// Headline answer to "is our cost going up?".
class _OutlookBanner extends GetView<UsageController> {
  const _OutlookBanner();

  @override
  Widget build(BuildContext context) {
    final outlook = controller.outlook;
    final delta = controller.costDeltaPercent;
    final days = controller.rangeDays.value;

    final (color, icon, headline) = switch (outlook) {
      CostOutlook.rising => (
        AppColors.danger,
        Icons.trending_up,
        'Spend is trending up',
      ),
      CostOutlook.falling => (
        AppColors.success,
        Icons.trending_down,
        'Spend is trending down',
      ),
      CostOutlook.stable => (
        AppColors.info,
        Icons.trending_flat,
        'Spend is holding steady',
      ),
    };

    final detail = delta == null
        ? 'Not enough history to compare with the previous $days days.'
        : '${delta.abs().toStringAsFixed(1)}% '
              '${delta >= 0 ? 'higher' : 'lower'} than the previous $days days. '
              'Projected month-end total is '
              '${usd(controller.projectedMonthCost)}.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends GetView<UsageController> {
  const _KpiGrid();

  @override
  Widget build(BuildContext context) {
    final w = controller.window;
    final latest = controller.latest;

    final cards = <(IconData, String, String, double?, String, Color)>[
      (
        Icons.menu_book_outlined,
        'Document reads',
        compactNumber(controller.totalReads(w)),
        controller.readsDeltaPercent,
        'vs previous period',
        AppColors.primary,
      ),
      (
        Icons.edit_note_outlined,
        'Document writes',
        compactNumber(controller.totalWrites(w)),
        controller.writesDeltaPercent,
        'vs previous period',
        AppColors.purple,
      ),
      (
        Icons.folder_outlined,
        'Storage used',
        latest == null ? '—' : dataSizeLabel(latest.storedBytes),
        controller.storageDeltaPercent,
        'Firestore + Cloud Storage',
        AppColors.info,
      ),
      (
        Icons.cloud_download_outlined,
        'Network egress',
        dataSizeLabel(controller.totalEgress(w)),
        controller.egressDeltaPercent,
        'vs previous period',
        AppColors.accent,
      ),
      (
        Icons.payments_outlined,
        'Projected this month',
        usd(controller.projectedMonthCost),
        controller.costDeltaPercent,
        'month-to-date + forecast',
        AppColors.warning,
      ),
    ];

    final count = Responsive.pick(context, mobile: 2, tablet: 3, desktop: 5);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisExtent: 104,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => StatCard(
        icon: cards[i].$1,
        label: cards[i].$2,
        value: cards[i].$3,
        deltaPercent: cards[i].$4,
        compareLabel: cards[i].$5,
        iconColor: cards[i].$6,
      ),
    );
  }
}

class _CostTrendCard extends GetView<UsageController> {
  const _CostTrendCard();

  @override
  Widget build(BuildContext context) {
    final w = controller.window;
    final costs = controller.dailyCosts;
    // A 90-day axis cannot fit 90 labels; thin them to roughly six ticks.
    final step = (w.length / 6).ceil().clamp(1, 30);

    return SectionCard(
      title: 'Daily spend — last ${controller.rangeDays.value} days',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wraps rather than a Row: three money figures do not fit side by
          // side on a phone.
          Wrap(
            spacing: 22,
            runSpacing: 12,
            children: [
              _Metric(label: 'Period total', value: usd(controller.windowCost)),
              _Metric(
                label: 'Avg / day (7d)',
                value: usd(controller.recentDailyAverage),
              ),
              _Metric(
                label: 'Month to date',
                value: usd(controller.monthToDateCost),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ActivityLineChart(
            values: costs,
            labels: [
              for (var i = 0; i < w.length; i++)
                i % step == 0 ? DateFormatShort.of(w[i].date) : '',
            ],
            height: 240,
            color: AppColors.warning,
            axisFormatter: usd,
            tooltipFormatter: usd,
            // Daily spend is single-digit dollars; the default floor of 10
            // would flatten the whole series onto the axis.
            minTop: 1,
            axisReservedSize: 48,
          ),
        ],
      ),
    );
  }
}

/// Compact `d MMM` label for dense axes.
class DateFormatShort {
  DateFormatShort._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String of(DateTime d) => '${d.day} ${_months[d.month - 1]}';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.palette.textSecondary,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Free allowance still applies on Blaze; crossing it is what starts billing.
class _QuotaCard extends GetView<UsageController> {
  const _QuotaCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Today's free allowance",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final q in controller.quotas) ...[
            _QuotaRow(quota: q),
            const SizedBox(height: 14),
          ],
          Text(
            'Blaze keeps the daily free tier — you are only billed on the '
            'excess above these lines.',
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaRow extends StatelessWidget {
  const _QuotaRow({required this.quota});

  final QuotaLine quota;

  @override
  Widget build(BuildContext context) {
    final color = quota.isOver
        ? AppColors.danger
        : quota.isNear
        ? AppColors.warning
        : AppColors.success;
    String fmt(num v) =>
        quota.unitIsBytes ? dataSizeLabel(v) : groupedNumber(v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                quota.label,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${fmt(quota.used)} / ${fmt(quota.limit)}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: quota.fraction,
            minHeight: 7,
            backgroundColor: context.palette.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _ServiceBreakdownCard extends GetView<UsageController> {
  const _ServiceBreakdownCard();

  @override
  Widget build(BuildContext context) {
    final costs = controller.serviceCosts;
    final total = costs.fold<double>(0, (a, e) => a + e.$2);

    return SectionCard(
      title: 'Cost by service',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (service, cost) in costs) ...[
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _serviceColor(service),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _serviceLabel(service),
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Text(
                  usd(cost),
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 42,
                  child: Text(
                    total == 0
                        ? '—'
                        : '${(cost / total * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

String _serviceLabel(FirebaseService s) => switch (s) {
  FirebaseService.firestore => 'Cloud Firestore',
  FirebaseService.storage => 'Cloud Storage',
  FirebaseService.functions => 'Cloud Functions',
  FirebaseService.hosting => 'Hosting',
  FirebaseService.auth => 'Authentication',
};

Color _serviceColor(FirebaseService s) => switch (s) {
  FirebaseService.firestore => AppColors.primary,
  FirebaseService.storage => AppColors.info,
  FirebaseService.functions => AppColors.purple,
  FirebaseService.hosting => AppColors.accent,
  FirebaseService.auth => AppColors.warning,
};

/// Sets expectations about data freshness and where the numbers come from.
class _SourceNote extends StatelessWidget {
  const _SourceNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.palette.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 17,
            color: context.palette.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sample data. Live figures come from Cloud Monitoring via an '
              'authenticated Cloud Function (Phase 3). Read and write counts '
              'lag by a few minutes; stored bytes are sampled once daily. '
              'Costs are estimated from list prices — the invoiced amount '
              'comes from your billing export.',
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
