import 'package:flutter/material.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_action_badge.dart';

/// Card displaying an audit log entry on compact mobile screens.
class AuditLogsMobileCard extends StatelessWidget {
  final AuditLog log;

  const AuditLogsMobileCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final l = log;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarCircle(name: l.adminName, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.adminName,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${l.module} • ${formatDate(l.time)}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                AuditActionBadge(action: l.action),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.details,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
