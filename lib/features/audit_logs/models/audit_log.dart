import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

enum AuditAction {
  created,
  updated,
  deleted,
  viewed,
  downloaded,
  exported,
  failedLogin;

  String get label => switch (this) {
        AuditAction.created => 'Created',
        AuditAction.updated => 'Updated',
        AuditAction.deleted => 'Deleted',
        AuditAction.viewed => 'Viewed',
        AuditAction.downloaded => 'Downloaded',
        AuditAction.exported => 'Exported',
        AuditAction.failedLogin => 'Failed Login',
      };

  Color get color => switch (this) {
        AuditAction.created => AppColors.success,
        AuditAction.updated => AppColors.info,
        AuditAction.deleted => AppColors.danger,
        AuditAction.viewed => AppColors.accent,
        AuditAction.downloaded => AppColors.purple,
        AuditAction.exported => AppColors.purple,
        AuditAction.failedLogin => AppColors.danger,
      };
}

enum AuditStatus {
  success,
  failed;

  String get label => switch (this) {
        AuditStatus.success => 'Success',
        AuditStatus.failed => 'Failed',
      };

  Color get color => switch (this) {
        AuditStatus.success => AppColors.success,
        AuditStatus.failed => AppColors.danger,
      };
}

/// One admin action record. Phase 3: written by a cloud function on
/// every admin write/read of sensitive data.
class AuditLog {
  const AuditLog({
    required this.id,
    required this.time,
    required this.adminName,
    required this.adminRole,
    required this.action,
    required this.module,
    required this.details,
    required this.ip,
    required this.location,
    this.status = AuditStatus.success,
  });

  final String id;
  final DateTime time;
  final String adminName;
  final String adminRole;
  final AuditAction action;
  final String module;
  final String details;
  final String ip;
  final String location;
  final AuditStatus status;
}
