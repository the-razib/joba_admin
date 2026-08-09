import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/empty_state.dart';

class AdaptiveColumn<T> {
  const AdaptiveColumn({
    required this.label,
    required this.build,
    this.flex = 1,
    this.width,
    this.align = Alignment.centerLeft,
    this.tabletHidden = false,
  });

  final String label;
  final Widget Function(BuildContext context, T row) build;

  /// Share of the leftover width. Ignored when [width] is set.
  final int flex;

  /// Fixed width instead of a flex share. Use it for trailing action columns:
  /// a single icon button should not claim an equal slice of the table.
  final double? width;

  final Alignment align;
  final bool tabletHidden;
}

/// Desktop/tablet: column table. Mobile: stacked cards via [cardBuilder].
///
/// Cells are laid out inside an [Align], so a fixed-size child — a pill badge,
/// an icon button — hugs its own content instead of being stretched across the
/// whole column. Without it, two adjacent badge columns render as touching
/// full-width bars. A cell that genuinely wants the full width can ask for it
/// with `SizedBox(width: double.infinity)`.
class AdaptiveDataTable<T> extends StatelessWidget {
  const AdaptiveDataTable({
    super.key,
    required this.rows,
    required this.columns,
    required this.cardBuilder,
    this.onRowTap,
    this.empty,
    this.columnGap = 12,
  });

  final List<T> rows;
  final List<AdaptiveColumn<T>> columns;
  final Widget Function(BuildContext context, T row) cardBuilder;
  final void Function(T row)? onRowTap;
  final Widget? empty;

  /// Breathing room between columns. Applied identically to the header and the
  /// body so the two never drift out of alignment.
  final double columnGap;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return empty ??
          const EmptyState(
            icon: Icons.search_off,
            title: 'No results',
            subtitle: 'Try adjusting your search or filters.',
          );
    }

    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            InkWell(
              onTap: onRowTap == null ? null : () => onRowTap!(rows[i]),
              borderRadius: BorderRadius.circular(16),
              child: cardBuilder(context, rows[i]),
            ),
            if (i != rows.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    final cols = Responsive.isTablet(context)
        ? columns.where((c) => !c.tabletHidden).toList()
        : columns;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.palette.border)),
          ),
          child: Row(
            children: _laidOut(
              cols,
              (c) => Text(
                c.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        for (int i = 0; i < rows.length; i++) ...[
          InkWell(
            onTap: onRowTap == null ? null : () => onRowTap!(rows[i]),
            child: Container(
              color: i.isOdd
                  ? context.palette.textSecondary.withValues(alpha: 0.04)
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: _laidOut(cols, (c) => c.build(context, rows[i])),
              ),
            ),
          ),
          if (i != rows.length - 1)
            Divider(height: 1, color: context.palette.border),
        ],
      ],
    );
  }

  /// Sizes each cell by [AdaptiveColumn.width] or [AdaptiveColumn.flex] and
  /// separates them by [columnGap].
  List<Widget> _laidOut(
    List<AdaptiveColumn<T>> cols,
    Widget Function(AdaptiveColumn<T> c) child,
  ) {
    final out = <Widget>[];
    for (final c in cols) {
      if (out.isNotEmpty) out.add(SizedBox(width: columnGap));
      final cell = Align(alignment: c.align, child: child(c));
      out.add(
        c.width != null
            ? SizedBox(width: c.width, child: cell)
            : Expanded(flex: c.flex, child: cell),
      );
    }
    return out;
  }
}
