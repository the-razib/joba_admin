import 'package:flutter/material.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/features/audit_logs/views/widgets/audit_action_badge.dart';

/// Helper function to open the full slide-over audit log detail drawer.
void openAuditLogDetailPanel(BuildContext context, AuditLog log) {
  showDetailPanel(
    context,
    title: 'Log Details',
    child: AuditLogDetailBody(log: log),
  );
}

/// The body content of the audit log detail drawer.
class AuditLogDetailBody extends StatelessWidget {
  final AuditLog log;

  const AuditLogDetailBody({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final l = log;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(name: l.adminName, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.adminName,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${l.adminRole} • ${formatDateTime(l.time)}',
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AuditActionBadge(action: l.action),
            ],
          ),
          const SizedBox(height: 20),
          for (final row in [
            ('Module', l.module),
            ('Action', l.action.name),
            ('Details', l.details),
            ('IP Address', l.ip),
            ('Location', l.location),
            ('Status', l.status.name),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      row.$1,
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
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
