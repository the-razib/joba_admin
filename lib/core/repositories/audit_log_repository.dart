import 'package:joba_admin/features/audit_logs/models/audit_log.dart';

/// Repository interface for fetching and logging security events and audit records.
abstract class AuditLogRepository {
  Future<List<AuditLog>> seedLogs();
  Future<List<AuditLog>> fetchLogs({
    int limit = 100,
    String? module,
    String? action,
    String? search,
  });
  Future<void> recordLog(AuditLog log);
}

class MockAuditLogRepository implements AuditLogRepository {
  @override
  Future<List<AuditLog>> seedLogs() async {
    final now = DateTime.now();
    DateTime t(int hoursAgo) => now.subtract(Duration(hours: hoursAgo));
    return [
      AuditLog(
        id: 'AL-001',
        time: t(1),
        adminName: 'Md. Razib Hasan',
        adminRole: 'Super Admin',
        action: AuditAction.created,
        module: 'User Management',
        details: 'Created new user farhana@gmail.com',
        ip: '103.145.12.45',
        location: 'Bangladesh, Dhaka',
      ),
      AuditLog(
        id: 'AL-002',
        time: t(2),
        adminName: 'Farha Islam',
        adminRole: 'Editor',
        action: AuditAction.updated,
        module: 'Article',
        details: 'Updated article "Period Pain Relief Tips"',
        ip: '103.145.12.47',
        location: 'Bangladesh, Dhaka',
      ),
      AuditLog(
        id: 'AL-003',
        time: t(3),
        adminName: 'Sakib Ahmed',
        adminRole: 'Editor',
        action: AuditAction.deleted,
        module: 'Reminder',
        details: 'Deleted reminder ID: REM-2026-4587',
        ip: '103.145.12.51',
        location: 'Bangladesh, Chattogram',
      ),
      AuditLog(
        id: 'AL-004',
        time: t(4),
        adminName: 'Nusrat Jahan',
        adminRole: 'Viewer',
        action: AuditAction.viewed,
        module: 'Cycle Data',
        details: 'Viewed cycle data User ID: USR-12879',
        ip: '103.145.12.52',
        location: 'Bangladesh, Dhaka',
      ),
      AuditLog(
        id: 'AL-005',
        time: t(6),
        adminName: 'Md. Razib Hasan',
        adminRole: 'Super Admin',
        action: AuditAction.updated,
        module: 'App Settings',
        details: 'Updated app settings: notification preferences',
        ip: '103.145.12.45',
        location: 'Bangladesh, Dhaka',
      ),
      AuditLog(
        id: 'AL-006',
        time: t(8),
        adminName: 'Tanvir Hasan',
        adminRole: 'Editor',
        action: AuditAction.failedLogin,
        module: 'Authentication',
        details: 'Failed login attempt: incorrect password',
        ip: '203.112.45.67',
        location: 'Bangladesh, Dhaka',
        status: AuditStatus.failed,
      ),
      AuditLog(
        id: 'AL-007',
        time: t(10),
        adminName: 'Moumita Rahi',
        adminRole: 'Viewer',
        action: AuditAction.downloaded,
        module: 'Reports',
        details: 'Downloaded user report Type: All Users',
        ip: '103.145.12.64',
        location: 'Bangladesh, Sylhet',
      ),
      AuditLog(
        id: 'AL-008',
        time: t(12),
        adminName: 'Md. Razib Hasan',
        adminRole: 'Super Admin',
        action: AuditAction.created,
        module: 'Promo Code',
        details: 'Created promo code SUMMER2026',
        ip: '103.145.12.45',
        location: 'Bangladesh, Dhaka',
      ),
      AuditLog(
        id: 'AL-009',
        time: t(14),
        adminName: 'Farha Islam',
        adminRole: 'Editor',
        action: AuditAction.updated,
        module: 'User Role',
        details: 'Updated user role User: sakib@gmail.com',
        ip: '103.145.12.47',
        location: 'Bangladesh, Dhaka',
      ),
      AuditLog(
        id: 'AL-010',
        time: t(16),
        adminName: 'Sakib Ahmed',
        adminRole: 'Editor',
        action: AuditAction.exported,
        module: 'Cycle Data',
        details: 'Exported cycle data Format: CSV',
        ip: '103.145.12.51',
        location: 'Bangladesh, Chattogram',
      ),
      AuditLog(
        id: 'AL-011',
        time: t(26),
        adminName: 'Farha Islam',
        adminRole: 'Editor',
        action: AuditAction.created,
        module: 'Article',
        details: 'Created article "Foods to Eat During Menstruation"',
        ip: '103.145.12.47',
        location: 'Bangladesh, Dhaka',
      ),
      AuditLog(
        id: 'AL-012',
        time: t(30),
        adminName: 'Md. Razib Hasan',
        adminRole: 'Super Admin',
        action: AuditAction.updated,
        module: 'Avatar',
        details: 'Published 3 avatars to category hijab',
        ip: '103.145.12.45',
        location: 'Bangladesh, Dhaka',
      ),
      AuditLog(
        id: 'AL-013',
        time: t(49),
        adminName: 'Tanvir Hasan',
        adminRole: 'Editor',
        action: AuditAction.failedLogin,
        module: 'Authentication',
        details: 'Failed login attempt: unknown account',
        ip: '203.112.45.67',
        location: 'Bangladesh, Dhaka',
        status: AuditStatus.failed,
      ),
      AuditLog(
        id: 'AL-014',
        time: t(52),
        adminName: 'Moumita Rahi',
        adminRole: 'Viewer',
        action: AuditAction.viewed,
        module: 'Users',
        details: 'Viewed user profile USR-10432',
        ip: '103.145.12.64',
        location: 'Bangladesh, Sylhet',
      ),
    ];
  }

  @override
  Future<List<AuditLog>> fetchLogs({
    int limit = 100,
    String? module,
    String? action,
    String? search,
  }) async {
    var list = await seedLogs();
    if (module != null && module.isNotEmpty && module != 'All Modules') {
      list = list.where((l) => l.module == module).toList();
    }
    if (action != null && action.isNotEmpty && action != 'All Actions') {
      list = list
          .where(
            (l) =>
                l.action.name.toLowerCase() ==
                action.toLowerCase().replaceAll(' ', ''),
          )
          .toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list
          .where(
            (l) =>
                l.adminName.toLowerCase().contains(q) ||
                l.details.toLowerCase().contains(q) ||
                l.module.toLowerCase().contains(q) ||
                l.ip.contains(q),
          )
          .toList();
    }
    return list.take(limit).toList();
  }

  @override
  Future<void> recordLog(AuditLog log) async {}
}
