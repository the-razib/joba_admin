import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/reminder_template.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';

Color _kindColor(ReminderKind k) => switch (k) {
  ReminderKind.pad => const Color(0xFF7B61FF),
  ReminderKind.periodPrep => const Color(0xFFE65671),
  ReminderKind.medicine => const Color(0xFF00BCD4),
};

Widget _buildReminderAssetIcon(ReminderKind k, {double size = 24}) {
  switch (k) {
    case ReminderKind.pad:
      return SvgPicture.asset(
        'assets/icons/home/pad_reminder.svg',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    case ReminderKind.periodPrep:
      return SvgPicture.asset(
        'assets/icons/home/period_preparation.svg',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    case ReminderKind.medicine:
      return Image.asset(
        'assets/icons/reminder/medicine_reminder.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
  }
}

class RemindersScreen extends GetView<RemindersController> {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final isDesktop = Responsive.isDesktop(context);
      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Reminder Tracker',
                  subtitle:
                      'Control the order every user sees their pad, '
                      'period preparation and medicine reminders in.',
                  actions: const [_HeaderActions()],
                ),
                const SizedBox(height: 16),
                const _StatsGrid(),
                const SizedBox(height: 12),
                const _ScopeBanner(),
                const SizedBox(height: 16),
                if (isDesktop)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _OrderCard()),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _PreviewCard(),
                            SizedBox(height: 16),
                            _UsageCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const Column(
                    children: [
                      _OrderCard(),
                      SizedBox(height: 16),
                      _PreviewCard(),
                      SizedBox(height: 16),
                      _UsageCard(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _HeaderActions extends GetView<RemindersController> {
  const _HeaderActions();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dirty = controller.isDirty;
      final saving = controller.saving.value;
      return Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: dirty && !saving ? controller.resetOrder : null,
            icon: const Icon(Icons.restart_alt, size: 17),
            label: const Text('Reset'),
          ),
          ElevatedButton.icon(
            onPressed: dirty && !saving ? controller.saveOrder : null,
            icon: saving
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, size: 17),
            label: Text(saving ? 'Saving…' : 'Save Order'),
          ),
        ],
      );
    });
  }
}

class _StatsGrid extends GetView<RemindersController> {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = <(IconData, String, String, Color)>[
        (
          Icons.alarm_on_outlined,
          'Active Trackers',
          '${controller.trackerCount}',
          AppColors.purple,
        ),
        (
          Icons.groups_outlined,
          'Tracker Adoption',
          '${controller.adoptionPercent.toStringAsFixed(0)}%',
          AppColors.info,
        ),
        (
          Icons.layers_outlined,
          'Avg. per Tracker',
          controller.avgPerTracker.toStringAsFixed(1),
          AppColors.success,
        ),
        (
          Icons.notifications_off_outlined,
          'Not Tracking',
          '${controller.notTrackingCount}',
          AppColors.danger,
        ),
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.pick(
            context,
            mobile: 2,
            tablet: 4,
            desktop: 4,
          ),
          mainAxisExtent: 104,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => StatCard(
          icon: stats[i].$1,
          label: stats[i].$2,
          value: stats[i].$3,
          iconColor: stats[i].$4,
        ),
      );
    });
  }
}

class _ScopeBanner extends StatelessWidget {
  const _ScopeBanner();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This order is global. Users still choose which reminders to '
              'switch on and when medicine fires — the admin panel only decides '
              'the sequence they are planned in on the home screen.',
              style: TextStyle(color: palette.textPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends GetView<RemindersController> {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Home Screen Order',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => controller.isDirty
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _DirtyNotice(),
                  )
                : const SizedBox.shrink(),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              return Obx(
                () => ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: controller.move,
                  itemCount: controller.order.length,
                  itemBuilder: (context, i) {
                    final kind = controller.order[i];
                    return _ReminderTile(
                      key: ValueKey(kind),
                      kind: kind,
                      index: i,
                      isLast: i == controller.order.length - 1,
                      compact: compact,
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Responsive.isMobile(context)
                    ? Icons.touch_app_outlined
                    : Icons.drag_indicator,
                size: 14,
                color: context.palette.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  Responsive.isMobile(context)
                      ? 'Long-press a reminder to drag it, or use the arrows.'
                      : 'Drag the handle or use the arrows to reorder.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DirtyNotice extends StatelessWidget {
  const _DirtyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 15, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unsaved changes — press Save Order to publish this sequence.',
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single row in the order list with authentic app icon
class _ReminderTile extends GetView<RemindersController> {
  const _ReminderTile({
    super.key,
    required this.kind,
    required this.index,
    required this.isLast,
    required this.compact,
  });

  final ReminderKind kind;
  final int index;
  final bool isLast;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _kindColor(kind);
    final palette = context.palette;
    final tracked = controller.trackersOf(kind);
    final adoption = controller.adoptionOf(kind);

    final body = Container(
      padding: EdgeInsets.fromLTRB(compact ? 12 : 10, 12, 10, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!compact) ...[
                ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 20,
                        color: color.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              _RankBadge(rank: index + 1, color: color),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: _buildReminderAssetIcon(kind, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kind.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      kind.labelBn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bengali(
                        context,
                        fontSize: 11.5,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _MoveButtons(index: index, isLast: isLast),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule, size: 13, color: palette.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  kind.scheduleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$tracked users',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${adoption.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (adoption / 100).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 12 : 10),
      child: compact
          ? ReorderableDelayedDragStartListener(index: index, child: body)
          : body,
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.color});

  final int rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$rank',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MoveButtons extends GetView<RemindersController> {
  const _MoveButtons({required this.index, required this.isLast});

  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MoveButton(
          icon: Icons.keyboard_arrow_up,
          tooltip: 'Move up',
          onPressed: index == 0 ? null : () => controller.moveUp(index),
        ),
        const SizedBox(height: 2),
        _MoveButton(
          icon: Icons.keyboard_arrow_down,
          tooltip: 'Move down',
          onPressed: isLast ? null : () => controller.moveDown(index),
        ),
      ],
    );
  }
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? context.palette.card
                : context.palette.card.withValues(alpha: 0.4),
            border: Border.all(color: context.palette.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 17,
            color: enabled
                ? context.palette.textPrimary
                : context.palette.textSecondary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

/// Authentic mobile home screen mockup rendering the actual 1:1 reminder cards
class _PreviewCard extends GetView<RemindersController> {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Home Screen Preview',
      child: Column(
        children: [
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2227),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF2E353D), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Status Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '9:41',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1D20),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111417),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.wifi, size: 12, color: Color(0xFF1A1D20)),
                              SizedBox(width: 4),
                              Icon(Icons.battery_full, size: 13, color: Color(0xFF1A1D20)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Section Title in Mobile App Style
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'আজকের রিমাইন্ডার ও পরামর্শ',
                              style: TextStyle(
                                color: Color(0xFF1A1D20),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 1:1 Horizontal Scrolling Mobile Cards Preview
                    Obx(
                      () => SizedBox(
                        height: 138,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.order.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final kind = controller.order[i];
                            return _MobileMockReminderCard(
                              kind: kind,
                              rank: i + 1,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Live preview reflecting the exact horizontal card sequence on the Joba mobile home screen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// 1:1 Replica of Mobile App's _VerticalReminderCard
class _MobileMockReminderCard extends StatelessWidget {
  const _MobileMockReminderCard({
    required this.kind,
    required this.rank,
  });

  final ReminderKind kind;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = _kindColor(kind);

    return Container(
      width: 104,
      height: 136,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Title + Notification Bell Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _mockTitle(kind),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    size: 10,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Illustration Area with the authentic Mobile Asset
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 4),
              child: Center(
                child: _buildReminderAssetIcon(kind, size: 52),
              ),
            ),
          ),

          // Sequence Badge at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                'Position #$rank',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _mockTitle(ReminderKind k) => switch (k) {
    ReminderKind.pad => 'প্যাড',
    ReminderKind.periodPrep => 'প্রস্তুতি',
    ReminderKind.medicine => 'মেডিসিন',
  };
}

class _UsageCard extends GetView<RemindersController> {
  const _UsageCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Reminder Usage',
      child: Obx(
        () => DonutChart(
          centerValue: '${controller.trackerCount}',
          centerLabel: 'Trackers',
          size: 160,
          slices: [
            for (final (kind, count) in controller.kindCounts)
              DonutSlice(kind.label, count.toDouble(), _kindColor(kind)),
          ],
        ),
      ),
    );
  }
}
