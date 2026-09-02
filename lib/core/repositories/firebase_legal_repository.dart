import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:joba_admin/core/repositories/legal_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/legal/data/default_legal_data.dart';
import 'package:joba_admin/features/legal/models/legal_document_admin_model.dart';

/// Firebase Cloud Firestore implementation for legal documents.
/// Backed by the `app_config/{docId}` collection.
class FirebaseLegalRepository implements LegalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('app_config');

  @override
  Future<LegalDocumentAdminModel?> getDocument(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return LegalDocumentAdminModel.fromMap(doc.data()!, id);
      }

      // If document does not exist yet in Firestore, provide default template
      debugPrint('⚡ [LegalRepository] Document "$id" not found in Firestore. Providing default template.');
      return _defaultDocument(id);
    } catch (e) {
      debugPrint('❌ [LegalRepository] Failed to fetch document "$id": $e');
      return _defaultDocument(id);
    }
  }

  @override
  Future<void> saveDocument(LegalDocumentAdminModel doc) async {
    try {
      final data = doc.toMap();
      await _collection.doc(doc.id).set(data, SetOptions(merge: true));
      debugPrint('✅ [LegalRepository] Document "${doc.id}" saved successfully to Firestore.');

      // Audit logging
      try {
        await AuditService.log(
          module: 'Legal & Policies',
          action: AuditAction.updated,
          details: 'Updated legal document: ${doc.titleEn} (Version: ${doc.version})',
        );
      } catch (e) {
        debugPrint('Failed to log audit for legal document: $e');
      }
    } catch (e) {
      debugPrint('❌ [LegalRepository] Failed to save document "${doc.id}": $e');
      rethrow;
    }
  }

  LegalDocumentAdminModel _defaultDocument(String id) {
    if (id == 'privacy_policy') {
      return LegalDocumentAdminModel(
        id: 'privacy_policy',
        titleBn: 'গোপনীয়তা নীতি',
        titleEn: 'Privacy Policy',
        contentBn: DefaultLegalData.privacyPolicyBn,
        contentEn: DefaultLegalData.privacyPolicyEn,
        version: '1.0.0',
        updatedAt: DateTime.now(),
      );
    } else {
      return LegalDocumentAdminModel(
        id: 'terms_conditions',
        titleBn: 'নিয়ম ও শর্তাবলী',
        titleEn: 'Terms & Conditions',
        contentBn: DefaultLegalData.termsConditionsBn,
        contentEn: DefaultLegalData.termsConditionsEn,
        version: '1.0.0',
        updatedAt: DateTime.now(),
      );
    }
  }
}
