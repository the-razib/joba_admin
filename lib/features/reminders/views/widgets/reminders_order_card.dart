import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';
import 'package:joba_admin/features/reminders/views/widgets/reminder_icon_widget.dart';

/// The main card for viewing and reordering the home screen reminder list.
class RemindersOrderCard extends GetView<RemindersController> {
  const RemindersOrderCard({super.key});

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
    final color = kind.themeColor;
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
                  child: ReminderIconWidget(kind: kind, size: 24),
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
