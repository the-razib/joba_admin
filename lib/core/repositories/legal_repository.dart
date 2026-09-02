import 'package:joba_admin/features/legal/data/default_legal_data.dart';
import 'package:joba_admin/features/legal/models/legal_document_admin_model.dart';

/// Repository interface for legal documents (Privacy Policy, Terms & Conditions).
abstract class LegalRepository {
  /// Fetches a legal document by its [id] ('privacy_policy' or 'terms_conditions').
  Future<LegalDocumentAdminModel?> getDocument(String id);

  /// Saves or updates a legal document.
  Future<void> saveDocument(LegalDocumentAdminModel doc);
}

/// In-memory mock repository for testing and development.
class MockLegalRepository implements LegalRepository {
  final Map<String, LegalDocumentAdminModel> _storage = {
    'privacy_policy': LegalDocumentAdminModel(
      id: 'privacy_policy',
      titleBn: 'গোপনীয়তা নীতি',
      titleEn: 'Privacy Policy',
      contentBn: DefaultLegalData.privacyPolicyBn,
      contentEn: DefaultLegalData.privacyPolicyEn,
      version: '1.0.0',
      updatedAt: DateTime.now(),
    ),
    'terms_conditions': LegalDocumentAdminModel(
      id: 'terms_conditions',
      titleBn: 'নিয়ম ও শর্তাবলী',
      titleEn: 'Terms & Conditions',
      contentBn: DefaultLegalData.termsConditionsBn,
      contentEn: DefaultLegalData.termsConditionsEn,
      version: '1.0.0',
      updatedAt: DateTime.now(),
    ),
  };

  @override
  Future<LegalDocumentAdminModel?> getDocument(String id) async {
    return _storage[id];
  }

  @override
  Future<void> saveDocument(LegalDocumentAdminModel doc) async {
    _storage[doc.id] = doc;
  }
}
