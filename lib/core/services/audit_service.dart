import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';

/// Centralized service to log administrative actions and security events across the entire panel.
class AuditService {
  AuditService._();

  static Future<void> log({
    required String module,
    required AuditAction action,
    required String details,
    AuditStatus status = AuditStatus.success,
    String? adminName,
    String? adminRole,
    String? ip,
    String? location,
  }) async {
    try {
      if (!Get.isRegistered<AuditLogRepository>()) return;

      final auth = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
      final currentAdmin = auth?.user.value;

      final logEntry = AuditLog(
        id: '',
        time: DateTime.now(),
        adminName: adminName ?? currentAdmin?.name ?? 'Admin',
        adminRole: adminRole ?? currentAdmin?.role.label ?? 'Super Admin',
        action: action,
        module: module,
        details: details,
        ip: ip ?? '127.0.0.1',
        location: location ?? 'Web Console',
        status: status,
      );

      final repo = Get.find<AuditLogRepository>();
      await repo.recordLog(logEntry);
    } catch (e) {
      debugPrint('AuditService failed to record entry: $e');
    }
  }
}
