import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';
import 'package:joba_admin/features/reports/models/report.dart';

class FirebaseReportRepository implements ReportRepository {
  final FirebaseFirestore _firestore;

  FirebaseReportRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'reports';

  @override
  Future<List<Report>> seedReports() => fetchReports();

  @override
  Future<List<Report>> fetchReports({int limit = 100}) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map((doc) => Report.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (_) {
      final snap = await _firestore.collection(_collection).limit(limit).get();
      final list = snap.docs
          .map((doc) => Report.fromMap(doc.data(), docId: doc.id))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
  }

  @override
  Future<void> updateReportStatus(String id, ReportStatus status) async {
    await _firestore.collection(_collection).doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateReportPriority(String id, ReportPriority priority) async {
    await _firestore.collection(_collection).doc(id).update({
      'priority': priority.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAsRead(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteReport(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
