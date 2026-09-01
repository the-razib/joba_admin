import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';

/// Repository interface for remote application configuration documents.
/// Backed by the `app_config/*` collection in Firestore.
abstract class ConfigRepository {
  /// Fetches a configuration document by its [docId] (e.g. 'reminders', 'general', 'algorithm').
  Future<Map<String, dynamic>?> getDoc(String docId);

  /// Saves or updates a configuration document [docId] with [data].
  Future<void> saveDoc(String docId, Map<String, dynamic> data);
}

/// In-memory mock config repository for testing and development.
class MockConfigRepository implements ConfigRepository {
  final Map<String, Map<String, dynamic>> _storage = {
    'reminders': {
      'order': ['pad', 'periodPrep', 'medicine'],
      'updatedAt': DateTime.now().toIso8601String(),
    },
    'general': {
      'maintenanceMode': false,
      'forceUpdate': false,
      'minSupportedVersion': '1.0.0',
      'sathiAiEnabled': true,
      'articleAudioEnabled': false,
    },
    'algorithm': {
      'version': '1.0.0',
      'confidenceThreshold': 0.3,
      'wmaWeights': [0.35, 0.25, 0.20, 0.12, 0.08],
      'outlierWeightFactor': 0.3,
      'irregularVarianceThreshold': 5.0,
      'showIrregularWarning': true,
      'enableMedianFallback': true,
    },
  };

  @override
  Future<Map<String, dynamic>?> getDoc(String docId) async {
    return _storage[docId];
  }

  @override
  Future<void> saveDoc(String docId, Map<String, dynamic> data) async {
    _storage[docId] = {
      ...?_storage[docId],
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}

/// Production Firebase Firestore repository for `app_config/*` documents.
class FirebaseConfigRepository implements ConfigRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getDoc(String docId) async {
    try {
      final doc = await _firestore.collection('app_config').doc(docId).get();
      return doc.exists ? doc.data() : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveDoc(String docId, Map<String, dynamic> data) async {
    await _firestore.collection('app_config').doc(docId).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    AuditService.log(
      module: 'App Settings',
      action: AuditAction.updated,
      details: 'Updated app configuration for $docId',
    );
  }
}
