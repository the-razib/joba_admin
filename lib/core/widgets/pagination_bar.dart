import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.totalItems,
    this.pageSize = 10,
    required this.onPageChanged,
    this.onPageSizeChanged,
  });

  final int page;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;

  static const _gap = '…';
  static const _maxChips = 7;

  int get _totalPages => (totalItems / pageSize).ceil().clamp(1, 99999);

  /// First page, last page and a window around the current page, with gap
  /// markers wherever the sequence skips. Never yields more than [_maxChips]
  /// entries, so the bar keeps a stable width as the page changes.
  List<Object> get _pages {
    final total = _totalPages;
    if (total <= _maxChips) {
      return List<Object>.generate(total, (i) => i + 1);
    }

    final current = page.clamp(1, total);
    final window = <int>{1, total, current};
    if (current <= 4) {
      window.addAll([2, 3, 4, 5]);
    } else if (current >= total - 3) {
      window.addAll([total - 4, total - 3, total - 2, total - 1]);
    } else {
      window.addAll([current - 1, current + 1]);
    }

    final sorted = window.where((p) => p >= 1 && p <= total).toList()..sort();
    final out = <Object>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) out.add(_gap);
      out.add(sorted[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final total = _totalPages;
    final from = totalItems == 0 ? 0 : (page - 1) * pageSize + 1;
    final to = (page * pageSize).clamp(0, totalItems);
    final mobile = Responsive.isMobile(context);

    final summary = Text(
      'Showing $from to $to of $totalItems',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: palette.textSecondary, fontSize: 12.5),
    );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Arrow(
          icon: Icons.chevron_left,
          tooltip: 'Previous page',
          enabled: page > 1,
          onTap: () => onPageChanged(page - 1),
        ),
        if (mobile)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Page $page of $total',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          for (final p in _pages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: p is int
                  ? _PageChip(
                      label: '$p',
                      active: p == page,
                      onTap: () => onPageChanged(p),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _gap,
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    ),
            ),
        _Arrow(
          icon: Icons.chevron_right,
          tooltip: 'Next page',
          enabled: page < total,
          onTap: () => onPageChanged(page + 1),
        ),
        if (onPageSizeChanged != null) ...[
          const SizedBox(width: 10),
          PopupMenuButton<int>(
            tooltip: 'Rows per page',
            onSelected: onPageSizeChanged,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: palette.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pageSize / page',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
            itemBuilder: (_) => [
              for (final s in const [10, 20, 50])
                PopupMenuItem(value: s, child: Text('$s / page')),
            ],
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: controls,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: summary),
                const SizedBox(width: 12),
                controls,
              ],
            ),
    );
  }
}

/// Sized by its label rather than by the parent, so the chip stays a compact
/// square instead of stretching across the row.
class _PageChip extends StatelessWidget {
  const _PageChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: active ? AppColors.primary : context.palette.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : context.palette.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 34,
        height: 34,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: context.palette.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? context.palette.textPrimary
                : context.palette.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
    return enabled ? Tooltip(message: tooltip, child: button) : button;
  }
}
