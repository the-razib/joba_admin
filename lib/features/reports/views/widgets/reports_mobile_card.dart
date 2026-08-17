import 'package:flutter/material.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/features/reports/views/widgets/report_type_icon.dart';

/// Card displaying a single report entry on compact mobile screens.
class ReportsMobileCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const ReportsMobileCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReportTypeIcon(type: report.type),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${report.userName} • ${formatDate(report.date)}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onTap,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                reportTypeBadge(report.type),
                reportStatusBadge(report.status),
                reportPriorityBadge(report.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
