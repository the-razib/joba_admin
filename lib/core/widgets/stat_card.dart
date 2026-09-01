import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// KPI card: icon tile + label + value + delta vs previous period.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.deltaPercent,
    this.compareLabel = '',
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? deltaPercent;
  final String compareLabel;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final up = (deltaPercent ?? 0) >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (deltaPercent != null) ...[
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            up ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 11,
                            color: up ? AppColors.success : AppColors.danger,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${deltaPercent!.abs().toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: up ? AppColors.success : AppColors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (compareLabel.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              compareLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
