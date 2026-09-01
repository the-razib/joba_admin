import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/widgets/bilingual_text_field.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';

/// Modal dialog for adding or editing a bilingual article category with direct image upload,
/// full input validation with error borders, and adaptive real-time mobile preview.
class AddArticleCategoryDialog extends StatefulWidget {
  final ArticleCategory? categoryToEdit;

  const AddArticleCategoryDialog({super.key, this.categoryToEdit});

  static Future<void> show(BuildContext context, {ArticleCategory? category}) {
    return showDialog(
      context: context,
      builder: (_) => AddArticleCategoryDialog(categoryToEdit: category),
    );
  }

  @override
  State<AddArticleCategoryDialog> createState() =>
      _AddArticleCategoryDialogState();
}

class _AddArticleCategoryDialogState extends State<AddArticleCategoryDialog> {
  late final TextEditingController _bnNameController;
  late final TextEditingController _enNameController;
  late final TextEditingController _bnSubtitleController;
  late final TextEditingController _enSubtitleController;

  Uint8List? _uploadedImageBytes;
  String? _uploadedImageName;
  late bool _isFullWidth;
  bool _hasAttemptedSave = false;

  @override
  void initState() {
    super.initState();
    final cat = widget.categoryToEdit;
    _bnNameController = TextEditingController(text: cat?.nameBn ?? '');
    _enNameController = TextEditingController(text: cat?.nameEn ?? '');
    _bnSubtitleController = TextEditingController(text: cat?.subtitleBn ?? '');
    _enSubtitleController = TextEditingController(text: cat?.subtitleEn ?? '');
    _isFullWidth = cat?.isFullWidth ?? false;

    // Listen to text updates to refresh the preview live
    _bnNameController.addListener(_onTextChanged);
    _bnSubtitleController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bnNameController.removeListener(_onTextChanged);
    _bnSubtitleController.removeListener(_onTextChanged);
    _bnNameController.dispose();
    _enNameController.dispose();
    _bnSubtitleController.dispose();
    _enSubtitleController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      setState(() {
        _uploadedImageBytes = file.bytes;
        _uploadedImageName = file.name;
        _hasAttemptedSave = false;
      });
    }
  }

  void _removeUploadedImage() {
    setState(() {
      _uploadedImageBytes = null;
      _uploadedImageName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticlesController>();
    final isEditing = widget.categoryToEdit != null;
    final palette = context.palette;

    final hasExistingImage =
        widget.categoryToEdit != null && widget.categoryToEdit!.imagePath.isNotEmpty;
    final hasImage =
        (_uploadedImageBytes != null && _uploadedImageBytes!.isNotEmpty) || hasExistingImage;
    final isImageMissing = _hasAttemptedSave && !hasImage;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.category_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Category' : 'New Category',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Configure topic details, card size & background for mobile',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 18),

              // 1. Bilingual Category Name (with error border when missing)
              BilingualField(
                label: 'Category Name *',
                bnController: _bnNameController,
                enController: _enNameController,
                bnErrorText: _hasAttemptedSave && _bnNameController.text.trim().isEmpty
                    ? 'বাংলা ক্যাটাগরি নাম দিন'
                    : null,
                enErrorText: _hasAttemptedSave && _enNameController.text.trim().isEmpty
                    ? 'English category name is required'
                    : null,
                onBnChanged: (_) {
                  if (_hasAttemptedSave) setState(() {});
                },
                onEnChanged: (_) {
                  if (_hasAttemptedSave) setState(() {});
                },
                hintBn: 'যেমন: যত্ন, পিরিয়ড, মেনোপজ, ডিসচার্জ',
                hintEn: 'e.g. Care, Period, Menopause, Discharge',
              ),
              const SizedBox(height: 14),

              // 2. Bilingual Subtitle
              BilingualField(
                label: 'Category Subtitle (Mobile Card Description)',
                bnController: _bnSubtitleController,
                enController: _enSubtitleController,
                hintBn: 'যেমন: শারীরিক ও মানসিক, হাইজিন ও অন্যান্য, ডিজিজ সম্পর্কিত',
                hintEn: 'e.g. Physical & Mental, Hygiene & More, Disease Related',
              ),
              const SizedBox(height: 18),

              // 3. Mobile Card Layout Selector
              Text(
                'Mobile Card Layout & Orientation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _layoutOptionCard(
                      context,
                      isFull: true,
                      title: 'Full Width Hero',
                      subtitle: '100% Width • 16:9 Aspect',
                      recommendedSize: '1080 × 600 px (360 × 190 dp)',
                      isSelected: _isFullWidth,
                      onTap: () => setState(() => _isFullWidth = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _layoutOptionCard(
                      context,
                      isFull: false,
                      title: 'Half Width Grid',
                      subtitle: '2-Col Side-by-Side • 1:1 Aspect',
                      recommendedSize: '600 × 600 px (170 × 186 dp)',
                      isSelected: !_isFullWidth,
                      onTap: () => setState(() => _isFullWidth = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. Photorealistic Cover Image Upload & Adaptive Card Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cover Photo Preview (${_isFullWidth ? "Full Width" : "Half Width"}) *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isImageMissing ? Colors.red : palette.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _isFullWidth ? 'Recommended: 1080 × 600 px' : 'Recommended: 600 × 600 px',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Adaptive Live Preview Container (shows red error border if missing)
              _buildAdaptiveLivePreview(context, hasError: isImageMissing),
              const SizedBox(height: 12),

              // Direct Image Upload Action & Selected File Status
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImageFile,
                    icon: const Icon(Icons.cloud_upload_outlined, size: 17),
                    label: Text(
                      _uploadedImageBytes != null || hasExistingImage
                          ? 'Change Image'
                          : 'Upload Image',
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isImageMissing ? Colors.red : AppColors.primary,
                        width: isImageMissing ? 1.5 : 1.0,
                      ),
                      foregroundColor: isImageMissing ? Colors.red : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_uploadedImageBytes != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              _uploadedImageName ?? 'New Image Selected',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: _removeUploadedImage,
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (hasExistingImage) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: palette.inputFill,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: palette.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 15,
                            color: palette.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Current Image Active',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Image Error message
              if (isImageMissing) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.error_outline, size: 14, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      'ক্যাটাগরির জন্য কভার ছবি আপলোড করা আবশ্যক (Cover photo is required)',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final nameBn = _bnNameController.text.trim();
                      final nameEn = _enNameController.text.trim();
                      final hasValidImage = (_uploadedImageBytes != null &&
                              _uploadedImageBytes!.isNotEmpty) ||
                          hasExistingImage;

                      if (nameBn.isEmpty || nameEn.isEmpty || !hasValidImage) {
                        setState(() {
                          _hasAttemptedSave = true;
                        });
                        if (nameBn.isEmpty || nameEn.isEmpty) {
                          AppToast.warning(
                            'Missing Information',
                            'Please provide category name in both Bengali and English.',
                          );
                        } else {
                          AppToast.warning(
                            'Cover Photo Required',
                            'Please upload a cover image for this category.',
                          );
                        }
                        return;
                      }

                      final subtitleBn = _bnSubtitleController.text.trim();
                      final subtitleEn = _enSubtitleController.text.trim();

                      if (isEditing) {
                        final updated = widget.categoryToEdit!.copyWith(
                          nameBn: nameBn,
                          nameEn: nameEn,
                          subtitleBn: subtitleBn,
                          subtitleEn: subtitleEn,
                          isFullWidth: _isFullWidth,
                        );
                        controller.updateCategory(
                          updated,
                          imageBytes: _uploadedImageBytes,
                          imageName: _uploadedImageName ?? 'banner.jpg',
                        );
                      } else {
                        controller.addCategory(
                          nameBn: nameBn,
                          nameEn: nameEn,
                          subtitleBn: subtitleBn,
                          subtitleEn: subtitleEn,
                          imageBytes: _uploadedImageBytes,
                          imageName: _uploadedImageName ?? 'banner.jpg',
                          isFullWidth: _isFullWidth,
                        );
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(isEditing ? 'Save Changes' : 'Add Category'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _layoutOptionCard(
    BuildContext context, {
    required bool isFull,
    required String title,
    required String subtitle,
    required String recommendedSize,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : palette.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : palette.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFull ? Icons.view_stream_rounded : Icons.dashboard_customize_rounded,
                  size: 18,
                  color: isSelected ? AppColors.primary : palette.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : palette.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              recommendedSize,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveLivePreview(BuildContext context, {bool hasError = false}) {
    final title = _bnNameController.text.isNotEmpty
        ? _bnNameController.text
        : 'ক্যাটাগরি শিরোনাম';
    final subtitle = _bnSubtitleController.text.isNotEmpty
        ? _bnSubtitleController.text
        : 'সাবটাইটেল প্রিভিউ';

    if (_isFullWidth) {
      // Full Width Hero Card Preview
      return Container(
        height: 110,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError ? Colors.red : Colors.transparent,
            width: hasError ? 2.0 : 0.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreviewImage(),
            _darkGradient(),
            Positioned(
              left: 14,
              bottom: 10,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bengali(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bengali(context).copyWith(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Half Width Side-by-Side Simulation
      return Row(
        children: [
          // The edited category card
          Expanded(
            child: Container(
              height: 130,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasError ? Colors.red : AppColors.primary,
                  width: hasError ? 2.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPreviewImage(),
                  _darkGradient(),
                  Positioned(
                    left: 10,
                    bottom: 8,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bengali(context).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bengali(context).copyWith(
                            fontSize: 9.5,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Companion placeholder to show true 2-column layout context
          Expanded(
            child: Container(
              height: 130,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.palette.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.palette.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize_outlined,
                      size: 24,
                      color: context.palette.textSecondary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Companion Card (Col 2)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _darkGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }

  Widget _buildPreviewImage() {
    if (_uploadedImageBytes != null && _uploadedImageBytes!.isNotEmpty) {
      return Image.memory(
        _uploadedImageBytes!,
        key: ValueKey(_uploadedImageBytes.hashCode),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _fallbackPlaceholder(),
      );
    }
    final existingPath = widget.categoryToEdit?.imagePath.trim() ?? '';
    if (existingPath.isNotEmpty) {
      if (existingPath.startsWith('http://') || existingPath.startsWith('https://')) {
        return Image.network(
          existingPath,
          key: ValueKey(existingPath),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _fallbackPlaceholder(),
        );
      }
      return Image.asset(
        existingPath,
        key: ValueKey(existingPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackPlaceholder(),
      );
    }
    return _fallbackPlaceholder();
  }

  Widget _fallbackPlaceholder() {
    return Container(
      color: context.palette.inputFill,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: context.palette.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 6),
            Text(
              'No Cover Image',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
