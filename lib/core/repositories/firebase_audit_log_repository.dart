import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';

/// Production Firebase Audit Log Repository.
/// Reads and writes system security events and activity trail from Firestore collection `audit_logs`.
class FirebaseAuditLogRepository implements AuditLogRepository {
  final FirebaseFirestore _firestore;

  FirebaseAuditLogRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'audit_logs';

  @override
  Future<List<AuditLog>> seedLogs() => fetchLogs();

  @override
  Future<List<AuditLog>> fetchLogs({
    int limit = 150,
    String? module,
    String? action,
    String? search,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collection);

      if (module != null && module.isNotEmpty && module != 'All Modules') {
        query = query.where('module', isEqualTo: module);
      }

      if (action != null && action.isNotEmpty && action != 'All Actions') {
        final normalizedAction = action.toLowerCase().replaceAll(' ', '');
        query = query.where('action', isEqualTo: normalizedAction);
      }

      QuerySnapshot<Map<String, dynamic>> snap;
      try {
        snap = await query.orderBy('time', descending: true).limit(limit).get();
      } catch (_) {
        try {
          snap = await query.orderBy('createdAt', descending: true).limit(limit).get();
        } catch (_) {
          // Fallback in case composite index is still building in Firestore
          snap = await query.limit(limit).get();
        }
      }

      final logs = snap.docs
          .map((doc) => AuditLog.fromMap(doc.data(), docId: doc.id))
          .toList();

      var result = logs;
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        result = result
            .where(
              (l) =>
                  l.adminName.toLowerCase().contains(q) ||
                  l.details.toLowerCase().contains(q) ||
                  l.module.toLowerCase().contains(q) ||
                  l.ip.contains(q),
            )
            .toList();
      }

      result.sort((a, b) => b.time.compareTo(a.time));
      return result;
    } catch (e) {
      debugPrint('Error fetching audit logs from Firebase: $e');
      return [];
    }
  }

  @override
  Future<void> recordLog(AuditLog log) async {
    try {
      await _firestore.collection(_collection).add({
        'adminName': log.adminName,
        'adminRole': log.adminRole,
        'action': log.action.name,
        'module': log.module,
        'details': log.details,
        'ip': log.ip,
        'location': log.location,
        'status': log.status.name,
        'time': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error recording audit log to Firestore: $e');
    }
  }
}
