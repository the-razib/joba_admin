import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/legal_repository.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/legal/models/legal_document_admin_model.dart';

/// Controller managing legal documents (Privacy Policy and Terms & Conditions)
/// in the Joba Admin Panel.
class LegalAdminController extends GetxController {
  final LegalRepository _repository = Get.find<LegalRepository>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  // Active Document Tab: 0 = Privacy Policy, 1 = Terms & Conditions
  final RxInt activeDocTab = 0.obs;

  // Active Language Tab for current document: 0 = Bengali, 1 = English
  final RxInt activePrivacyLang = 0.obs;
  final RxInt activeTermsLang = 0.obs;

  // Privacy Policy Controllers
  final TextEditingController privacyTitleBnCtrl = TextEditingController();
  final TextEditingController privacyTitleEnCtrl = TextEditingController();
  final TextEditingController privacyContentBnCtrl = TextEditingController();
  final TextEditingController privacyContentEnCtrl = TextEditingController();
  final TextEditingController privacyVersionCtrl = TextEditingController();
  final Rx<DateTime> privacyUpdatedAt = DateTime.now().obs;

  // Terms & Conditions Controllers
  final TextEditingController termsTitleBnCtrl = TextEditingController();
  final TextEditingController termsTitleEnCtrl = TextEditingController();
  final TextEditingController termsContentBnCtrl = TextEditingController();
  final TextEditingController termsContentEnCtrl = TextEditingController();
  final TextEditingController termsVersionCtrl = TextEditingController();
  final Rx<DateTime> termsUpdatedAt = DateTime.now().obs;

  bool get canEdit {
    final role = Get.find<AuthService>().user.value?.role;
    return role == AdminRole.superAdmin || role == AdminRole.editor;
  }

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  @override
  void onClose() {
    privacyTitleBnCtrl.dispose();
    privacyTitleEnCtrl.dispose();
    privacyContentBnCtrl.dispose();
    privacyContentEnCtrl.dispose();
    privacyVersionCtrl.dispose();

    termsTitleBnCtrl.dispose();
    termsTitleEnCtrl.dispose();
    termsContentBnCtrl.dispose();
    termsContentEnCtrl.dispose();
    termsVersionCtrl.dispose();
    super.onClose();
  }

  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;

      // 1. Fetch Privacy Policy
      final privacyDoc = await _repository.getDocument('privacy_policy');
      if (privacyDoc != null) {
        privacyTitleBnCtrl.text = privacyDoc.titleBn;
        privacyTitleEnCtrl.text = privacyDoc.titleEn;
        privacyContentBnCtrl.text = privacyDoc.contentBn;
        privacyContentEnCtrl.text = privacyDoc.contentEn;
        privacyVersionCtrl.text = privacyDoc.version;
        privacyUpdatedAt.value = privacyDoc.updatedAt;
      }

      // 2. Fetch Terms & Conditions
      final termsDoc = await _repository.getDocument('terms_conditions');
      if (termsDoc != null) {
        termsTitleBnCtrl.text = termsDoc.titleBn;
        termsTitleEnCtrl.text = termsDoc.titleEn;
        termsContentBnCtrl.text = termsDoc.contentBn;
        termsContentEnCtrl.text = termsDoc.contentEn;
        termsVersionCtrl.text = termsDoc.version;
        termsUpdatedAt.value = termsDoc.updatedAt;
      }
    } catch (e) {
      AppToast.error('Failed to load legal documents: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCurrentDocument() async {
    if (!canEdit) {
      AppToast.error('You do not have permission to edit legal documents');
      return;
    }

    final isPrivacy = activeDocTab.value == 0;
    try {
      isSaving.value = true;
      final now = DateTime.now();

      if (isPrivacy) {
        final updatedDoc = LegalDocumentAdminModel(
          id: 'privacy_policy',
          titleBn: privacyTitleBnCtrl.text.trim().isEmpty ? 'গোপনীয়তা নীতি' : privacyTitleBnCtrl.text.trim(),
          titleEn: privacyTitleEnCtrl.text.trim().isEmpty ? 'Privacy Policy' : privacyTitleEnCtrl.text.trim(),
          contentBn: privacyContentBnCtrl.text.trim(),
          contentEn: privacyContentEnCtrl.text.trim(),
          version: privacyVersionCtrl.text.trim().isEmpty ? '1.0.0' : privacyVersionCtrl.text.trim(),
          updatedAt: now,
        );

        await _repository.saveDocument(updatedDoc);
        privacyUpdatedAt.value = now;
        AppToast.success('Privacy Policy updated and synced live!');
      } else {
        final updatedDoc = LegalDocumentAdminModel(
          id: 'terms_conditions',
          titleBn: termsTitleBnCtrl.text.trim().isEmpty ? 'নিয়ম ও শর্তাবলী' : termsTitleBnCtrl.text.trim(),
          titleEn: termsTitleEnCtrl.text.trim().isEmpty ? 'Terms & Conditions' : termsTitleEnCtrl.text.trim(),
          contentBn: termsContentBnCtrl.text.trim(),
          contentEn: termsContentEnCtrl.text.trim(),
          version: termsVersionCtrl.text.trim().isEmpty ? '1.0.0' : termsVersionCtrl.text.trim(),
          updatedAt: now,
        );

        await _repository.saveDocument(updatedDoc);
        termsUpdatedAt.value = now;
        AppToast.success('Terms & Conditions updated and synced live!');
      }
    } catch (e) {
      AppToast.error('Failed to save document: $e');
    } finally {
      isSaving.value = false;
    }
  }
}
