enum AuditAction { created, updated, deleted, viewed, downloaded, exported, failedLogin }

enum AuditStatus { success, failed }

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
