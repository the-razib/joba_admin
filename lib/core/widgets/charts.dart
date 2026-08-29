import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';

/// Area line chart for activity overviews.
class ActivityLineChart extends StatelessWidget {
  const ActivityLineChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 260,
    this.color = AppColors.primary,
    this.axisFormatter,
    this.tooltipFormatter,
    this.minTop = 10,
    this.axisReservedSize = 34,
  });

  final List<double> values;
  final List<String> labels;
  final double height;
  final Color color;

  /// Y-axis tick label. Defaults to a compact count.
  final String Function(double value)? axisFormatter;

  /// Tooltip value line. Defaults to a compact user count.
  final String Function(double value)? tooltipFormatter;

  /// Smallest acceptable Y ceiling. Stops a chart of two or three users from
  /// drawing a dramatic cliff. Series measured in small units — money, rates —
  /// must lower this, or the line flattens onto the axis floor.
  final double minTop;

  /// Width of the Y-axis gutter. Widen it for formatters that emit long labels
  /// (`$1,240`); the default fits a compact count and wraps beyond ~6 glyphs.
  final double axisReservedSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];
    final maxY = (values.fold<double>(0, (a, b) => a > b ? a : b) * 1.25)
        .clamp(minTop, double.infinity)
        .toDouble();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: palette.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: axisReservedSize,
                getTitlesWidget: (v, _) => Text(
                  (axisFormatter ?? compactNumber)(v),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(color: palette.textSecondary, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E293B),
              tooltipRoundedRadius: 8,
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tooltipMargin: 8,
              getTooltipItems: (spots) => spots.map((s) {
                final i = s.x.toInt();
                final label = i < labels.length ? labels[i] : '';
                final value = tooltipFormatter != null
                    ? tooltipFormatter!(s.y)
                    : '${compactNumber(s.y)} users';
                return LineTooltipItem(
                  '$value\n',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: label,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 3,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: palette.card,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.22),
                    color.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonutSlice {
  const DonutSlice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

/// Donut chart with legend; stacks vertically on narrow screens.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    required this.centerValue,
    this.centerLabel = 'Total',
    this.size = 180,
  });

  final List<DonutSlice> slices;
  final String centerValue;
  final String centerLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final total = slices.fold<double>(0, (a, s) => a + s.value);

    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow =
            c.maxWidth < 300 && (!c.hasBoundedHeight || c.maxHeight >= 320);

        final effectiveSize = isNarrow
            ? size
            : (c.hasBoundedHeight
                ? size.clamp(100.0, (c.maxHeight - 16.0).clamp(100.0, size))
                : (c.maxWidth < 380
                    ? (c.maxWidth * 0.42).clamp(120.0, size)
                    : size));

        final chart = SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: effectiveSize * 0.32,
              centerSpaceColor: Colors.transparent,
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                    value: s.value,
                    color: s.color,
                    radius: effectiveSize * 0.16,
                    title: '',
                  ),
              ],
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        );

        final center = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              centerValue,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: effectiveSize < 140 ? 14 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              centerLabel,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: effectiveSize < 140 ? 9.5 : 11,
              ),
            ),
          ],
        );

        final legend = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in slices) ...[
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: palette.textPrimary, fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${total == 0 ? 0 : (s.value / total * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        );

        if (isNarrow) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(alignment: Alignment.center, children: [chart, center]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: legend),
            ],
          );
        }

        return Row(
          children: [
            Stack(alignment: Alignment.center, children: [chart, center]),
            const SizedBox(width: 16),
            Expanded(child: legend),
          ],
        );
      },
    );
  }
}
