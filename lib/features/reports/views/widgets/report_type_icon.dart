import 'package:flutter/material.dart';
import 'package:joba_admin/features/reports/models/report.dart';

/// Reusable icon container displaying the icon and theme color for a [ReportType].
class ReportTypeIcon extends StatelessWidget {
  final ReportType type;
  final double size;
  final double iconSize;

  const ReportTypeIcon({
    super.key,
    required this.type,
    this.size = 38,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(type.icon, size: iconSize, color: color),
    );
  }
}
