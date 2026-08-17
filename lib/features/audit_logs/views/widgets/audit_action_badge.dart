import 'package:flutter/material.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/core/widgets/badges.dart';

/// Reusable pill badge displaying the action taken in an audit log entry.
class AuditActionBadge extends StatelessWidget {
  final AuditAction action;

  const AuditActionBadge({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return PillBadge(
      label: action.label,
      color: action.color,
    );
  }
}
