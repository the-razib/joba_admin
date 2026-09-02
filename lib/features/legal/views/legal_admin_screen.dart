import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/core/widgets/rich_markdown_editor.dart';
import 'package:joba_admin/features/legal/controllers/legal_admin_controller.dart';

/// Screen for managing application Legal Documents (Privacy Policy & Terms & Conditions).
class LegalAdminScreen extends StatelessWidget {
  const LegalAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LegalAdminController());
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, controller),
                  const SizedBox(height: 20),
                  _buildDocTabs(context, controller),
                  const SizedBox(height: 16),
                  controller.activeDocTab.value == 0
                      ? _buildPrivacyPolicyEditor(context, controller)
                      : _buildTermsEditor(context, controller),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, LegalAdminController controller) {
    final palette = context.palette;
    final isPrivacy = controller.activeDocTab.value == 0;
    final updatedDate = isPrivacy
        ? controller.privacyUpdatedAt.value
        : controller.termsUpdatedAt.value;

    return PageHeader(
      title: 'Legal & Compliance',
      subtitle:
          'Draft, edit, and publish Privacy Policy & Terms of Service with full Markdown support and live sync to the Joba mobile app.',
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_outlined,
                      size: 14, color: palette.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(updatedDate)}',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: (controller.canEdit && !controller.isSaving.value)
                  ? controller.saveCurrentDocument
                  : null,
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined, size: 16),
              label: Text(
                controller.isSaving.value
                    ? 'Publishing...'
                    : 'Publish ${isPrivacy ? 'Privacy Policy' : 'Terms'}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocTabs(BuildContext context, LegalAdminController controller) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildDocTabItem(
              context: context,
              title: 'Privacy Policy',
              icon: Icons.shield_outlined,
              isSelected: controller.activeDocTab.value == 0,
              onTap: () => controller.activeDocTab.value = 0,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildDocTabItem(
              context: context,
              title: 'Terms & Conditions',
              icon: Icons.gavel_outlined,
              isSelected: controller.activeDocTab.value == 1,
              onTap: () => controller.activeDocTab.value = 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTabItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : palette.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : palette.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyEditor(
      BuildContext context, LegalAdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaCard(
          context: context,
          versionCtrl: controller.privacyVersionCtrl,
          docName: 'Privacy Policy',
        ),
        const SizedBox(height: 16),
        _buildLangSelector(
          context: context,
          activeLang: controller.activePrivacyLang,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final isBn = controller.activePrivacyLang.value == 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(
                context: context,
                label: isBn ? 'শিরোনাম (বাংলা)' : 'Title (English)',
                controller: isBn
                    ? controller.privacyTitleBnCtrl
                    : controller.privacyTitleEnCtrl,
                hint: isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
              ),
              const SizedBox(height: 16),
              RichMarkdownEditor(
                label: isBn
                    ? 'গোপনীয়তা নীতি কন্টেন্ট (Markdown)'
                    : 'Privacy Policy Content (Markdown)',
                controller: isBn
                    ? controller.privacyContentBnCtrl
                    : controller.privacyContentEnCtrl,
                isBengali: isBn,
                hintText: 'Write Privacy Policy clauses in markdown...',
                minLines: 16,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTermsEditor(
      BuildContext context, LegalAdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaCard(
          context: context,
          versionCtrl: controller.termsVersionCtrl,
          docName: 'Terms & Conditions',
        ),
        const SizedBox(height: 16),
        _buildLangSelector(
          context: context,
          activeLang: controller.activeTermsLang,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final isBn = controller.activeTermsLang.value == 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(
                context: context,
                label: isBn ? 'শিরোনাম (বাংলা)' : 'Title (English)',
                controller: isBn
                    ? controller.termsTitleBnCtrl
                    : controller.termsTitleEnCtrl,
                hint: isBn ? 'নিয়ম ও শর্তাবলী' : 'Terms & Conditions',
              ),
              const SizedBox(height: 16),
              RichMarkdownEditor(
                label: isBn
                    ? 'শর্তাবলী কন্টেন্ট (Markdown)'
                    : 'Terms & Conditions Content (Markdown)',
                controller: isBn
                    ? controller.termsContentBnCtrl
                    : controller.termsContentEnCtrl,
                isBengali: isBn,
                hintText: 'Write Terms & Conditions clauses in markdown...',
                minLines: 16,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMetaCard({
    required BuildContext context,
    required TextEditingController versionCtrl,
    required String docName,
  }) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$docName Configuration',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Changes published here synchronize dynamically to the Joba mobile app. Mobile users cache this content for 3 days to minimize Firestore read costs.',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 140,
            child: TextField(
              controller: versionCtrl,
              decoration: const InputDecoration(
                labelText: 'Version Tag',
                hintText: '1.0.0',
                isDense: true,
                prefixIcon: Icon(Icons.tag, size: 16),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangSelector({
    required BuildContext context,
    required RxInt activeLang,
  }) {
    final palette = context.palette;
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: palette.border),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangChip(
              context: context,
              title: 'বাংলা (Bengali)',
              isSelected: activeLang.value == 0,
              onTap: () => activeLang.value = 0,
            ),
            const SizedBox(width: 4),
            _buildLangChip(
              context: context,
              title: 'English',
              isSelected: activeLang.value == 1,
              onTap: () => activeLang.value = 1,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLangChip({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : palette.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: palette.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: palette.border),
            ),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
