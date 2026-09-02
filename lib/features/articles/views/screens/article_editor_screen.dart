import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/reading_time_calculator.dart';
import 'package:joba_admin/core/widgets/audio_upload_field.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/core/widgets/image_upload_field.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/views/widgets/article_editor_bilingual_section.dart';
import 'package:joba_admin/features/articles/views/widgets/article_editor_media_section.dart';
import 'package:joba_admin/features/articles/views/widgets/article_editor_medical_section.dart';
import 'package:joba_admin/features/articles/views/widgets/article_editor_settings_sidebar.dart';

/// Bilingual article editor screen with dirty-checking, publishing validation,
/// BN + EN titles/subtitles/content, thumbnail, audio uploads, reviewer verification, tags, and SEO settings.
class ArticleEditorScreen extends StatefulWidget {
  const ArticleEditorScreen({
    super.key,
    required this.article,
    required this.isNew,
  });

  final Article article;
  final bool isNew;

  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  late final ArticlesController controller = Get.find();

  late final TextEditingController _titleBn;
  late final TextEditingController _titleEn;
  late final TextEditingController _subBn;
  late final TextEditingController _subEn;
  late final TextEditingController _contentBn;
  late final TextEditingController _contentEn;
  late final TextEditingController _slug;
  late final TextEditingController _seoTitle;
  late final TextEditingController _seoDesc;
  late final TextEditingController _order;
  late final TextEditingController _tagInput;
  late final TextEditingController _medicalReviewerBn;
  late final TextEditingController _medicalReviewerEn;
  late final TextEditingController _readingTime;

  late String _categoryId;
  late ArticleStatus _status;
  late bool _featured;
  late bool _isMedicallyReviewed;
  late final List<String> _tags;
  late String? _imagePath;
  late String? _audioBn;
  late String? _audioEn;

  ImagePick? _pickedImage;
  AudioPick? _pickedAudioBn;
  AudioPick? _pickedAudioEn;

  /// True when the user removed the existing remote media — the fields fire
  /// onChanged(null) for both "undo a fresh pick" and "remove saved media",
  /// so removal is resolved against the article's original value.
  bool _removedImage = false;
  bool _removedAudioBn = false;
  bool _removedAudioEn = false;

  @override
  void initState() {
    super.initState();
    final a = widget.article;
    _titleBn = TextEditingController(text: a.titleBn);
    _titleEn = TextEditingController(text: a.titleEn);
    _subBn = TextEditingController(text: a.subtitleBn);
    _subEn = TextEditingController(text: a.subtitleEn);
    _contentBn = TextEditingController(text: a.contentBn);
    _contentEn = TextEditingController(text: a.contentEn);
    _slug = TextEditingController(text: a.slug);
    _seoTitle = TextEditingController(text: a.seoTitle);
    _seoDesc = TextEditingController(text: a.seoDescription);
    _order = TextEditingController(text: '${a.displayOrder}');
    _tagInput = TextEditingController();
    _medicalReviewerBn = TextEditingController(text: a.medicalReviewerBn);
    _medicalReviewerEn = TextEditingController(text: a.medicalReviewerEn);
    final initialCalculated = ReadingTimeCalculator.calculate(
      contentBn: a.contentBn,
      contentEn: a.contentEn,
    );
    final initialTime = (widget.isNew || a.readingTimeMin <= 0)
        ? (initialCalculated > 0 ? initialCalculated : 1)
        : a.readingTimeMin;
    _readingTime = TextEditingController(text: '$initialTime');
    _categoryId = a.categoryId;
    _status = a.status;
    _featured = a.featured;
    _isMedicallyReviewed = a.isMedicallyReviewed;
    _tags = List.of(a.tags);
    _imagePath = a.imagePath.isEmpty ? null : a.imagePath;
    _audioBn = (a.audioBnPath?.isEmpty ?? true) ? null : a.audioBnPath;
    _audioEn = (a.audioEnPath?.isEmpty ?? true) ? null : a.audioEnPath;

    _contentBn.addListener(_onContentChanged);
    _contentEn.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    final autoMin = ReadingTimeCalculator.calculate(
      contentBn: _contentBn.text,
      contentEn: _contentEn.text,
    );
    if (autoMin > 0) {
      _readingTime.text = '$autoMin';
    }
  }

  bool get _isDirty {
    final a = widget.article;
    if (widget.isNew) {
      return _titleBn.text.trim().isNotEmpty ||
          _titleEn.text.trim().isNotEmpty ||
          _contentBn.text.trim().isNotEmpty ||
          _contentEn.text.trim().isNotEmpty ||
          _pickedImage != null ||
          _pickedAudioBn != null ||
          _pickedAudioEn != null;
    }
    final orderVal = int.tryParse(_order.text.trim()) ?? 0;
    final readingTimeVal = int.tryParse(_readingTime.text.trim()) ?? 3;
    return _titleBn.text != a.titleBn ||
        _titleEn.text != a.titleEn ||
        _subBn.text != a.subtitleBn ||
        _subEn.text != a.subtitleEn ||
        _contentBn.text != a.contentBn ||
        _contentEn.text != a.contentEn ||
        _categoryId != a.categoryId ||
        _status != a.status ||
        _featured != a.featured ||
        _isMedicallyReviewed != a.isMedicallyReviewed ||
        _medicalReviewerBn.text != a.medicalReviewerBn ||
        _medicalReviewerEn.text != a.medicalReviewerEn ||
        _slug.text != a.slug ||
        _seoTitle.text != a.seoTitle ||
        _seoDesc.text != a.seoDescription ||
        orderVal != a.displayOrder ||
        readingTimeVal != a.readingTimeMin ||
        !listEquals(_tags, a.tags) ||
        _pickedImage != null ||
        _pickedAudioBn != null ||
        _pickedAudioEn != null ||
        (_removedImage && a.imagePath.isNotEmpty) ||
        (_removedAudioBn && (a.audioBnPath?.isNotEmpty ?? false)) ||
        (_removedAudioEn && (a.audioEnPath?.isNotEmpty ?? false));
  }

  Future<void> _handleCancel() async {
    if (_isDirty) {
      final discard = await showConfirmDialog(
        context,
        title: 'Discard Unsaved Changes?',
        message:
            'You have unsaved changes in this article. Are you sure you want to leave without saving?',
        confirmLabel: 'Discard',
        danger: true,
      );
      if (discard == true) {
        controller.closeEditor();
      }
    } else {
      controller.closeEditor();
    }
  }

  @override
  void dispose() {
    _contentBn.removeListener(_onContentChanged);
    _contentEn.removeListener(_onContentChanged);
    for (final c in [
      _titleBn,
      _titleEn,
      _subBn,
      _subEn,
      _contentBn,
      _contentEn,
      _slug,
      _seoTitle,
      _seoDesc,
      _order,
      _tagInput,
      _medicalReviewerBn,
      _medicalReviewerEn,
      _readingTime,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final titleBnTrim = _titleBn.text.trim();
    final titleEnTrim = _titleEn.text.trim();
    final contentBnTrim = _contentBn.text.trim();
    final contentEnTrim = _contentEn.text.trim();

    if (titleBnTrim.isEmpty || titleEnTrim.isEmpty) {
      AppToast.warning(
        'Missing Titles',
        'Both বাংলা and English titles are required to save an article.',
      );
      return;
    }

    // Strong validation for publishing
    if (_status == ArticleStatus.published) {
      if (contentBnTrim.isEmpty || contentEnTrim.isEmpty) {
        AppToast.warning(
          'Incomplete Content for Publishing',
          'To publish this article, both বাংলা and English content bodies are required. Fill in the body or save as Draft / In Review.',
        );
        return;
      }
      if (_categoryId.isEmpty) {
        AppToast.warning(
          'Missing Category',
          'Please assign a category before publishing.',
        );
        return;
      }
    }

    if (_pickedImage != null &&
        (_pickedImage!.bytes == null || _pickedImage!.bytes!.isEmpty)) {
      AppToast.warning(
        'Cannot Read Image',
        'Selected image could not be loaded. Please choose another file.',
      );
      return;
    }
    if (_pickedAudioBn != null &&
        (_pickedAudioBn!.bytes == null || _pickedAudioBn!.bytes!.isEmpty)) {
      AppToast.warning(
        'Cannot Read Bangla Audio',
        'Selected audio file could not be loaded.',
      );
      return;
    }
    if (_pickedAudioEn != null &&
        (_pickedAudioEn!.bytes == null || _pickedAudioEn!.bytes!.isEmpty)) {
      AppToast.warning(
        'Cannot Read English Audio',
        'Selected audio file could not be loaded.',
      );
      return;
    }

    final orderVal = int.tryParse(_order.text.trim()) ?? 0;
    final readingTimeVal = int.tryParse(_readingTime.text.trim()) ?? 3;
    final updated = widget.article.copyWith(
      titleBn: titleBnTrim,
      titleEn: titleEnTrim,
      subtitleBn: _subBn.text.trim(),
      subtitleEn: _subEn.text.trim(),
      contentBn: contentBnTrim,
      contentEn: contentEnTrim,
      categoryId: _categoryId,
      status: _status,
      featured: _featured,
      displayOrder: orderVal,
      readingTimeMin: readingTimeVal,
      medicalReviewerBn: _medicalReviewerBn.text.trim(),
      medicalReviewerEn: _medicalReviewerEn.text.trim(),
      isMedicallyReviewed: _isMedicallyReviewed,
      tags: _tags,
      // Fresh picks keep the original value here — saveArticleWithMedia
      // replaces it with the uploaded Storage URL. Empty string clears the
      // field (removal), since copyWith cannot set an explicit null.
      imagePath: _pickedImage != null
          ? widget.article.imagePath
          : (_removedImage ? '' : widget.article.imagePath),
      audioBnPath: _pickedAudioBn != null
          ? widget.article.audioBnPath
          : (_removedAudioBn ? '' : widget.article.audioBnPath),
      audioEnPath: _pickedAudioEn != null
          ? widget.article.audioEnPath
          : (_removedAudioEn ? '' : widget.article.audioEnPath),
      slug: _slug.text.trim(),
      seoTitle: _seoTitle.text.trim(),
      seoDescription: _seoDesc.text.trim(),
    );

    // Show non-dismissible modal loading dialog with live upload logs
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: context.palette.card,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                child: Obx(() {
                  final statusText = controller.savingStatus.value.isNotEmpty
                      ? controller.savingStatus.value
                      : (widget.isNew ? 'Publishing article...' : 'Saving changes...');

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.isNew ? 'Publishing Article' : 'Saving Changes',
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: context.palette.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );

    try {
      await controller.saveArticleWithMedia(
        updated,
        previous: widget.isNew ? null : widget.article,
        imageBytes: _pickedImage?.bytes != null
            ? Uint8List.fromList(_pickedImage!.bytes!)
            : null,
        imageName: _pickedImage?.name ??
            _pickedImage?.path?.split(RegExp(r'[/\\]')).last ??
            'cover.jpg',
        audioBnBytes: _pickedAudioBn?.bytes != null
            ? Uint8List.fromList(_pickedAudioBn!.bytes!)
            : null,
        audioBnName: _pickedAudioBn?.name ?? 'audio_bn.mp3',
        audioEnBytes: _pickedAudioEn?.bytes != null
            ? Uint8List.fromList(_pickedAudioEn!.bytes!)
            : null,
        audioEnName: _pickedAudioEn?.name,
      );
    } finally {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);

    final contentSection = Column(
      children: [
        ArticleEditorBilingualSection(
          titleBn: _titleBn,
          titleEn: _titleEn,
          subBn: _subBn,
          subEn: _subEn,
          contentBn: _contentBn,
          contentEn: _contentEn,
        ),
        const SizedBox(height: 16),
        ArticleEditorMedicalSection(
          isMedicallyReviewed: _isMedicallyReviewed,
          medicalReviewerBn: _medicalReviewerBn,
          medicalReviewerEn: _medicalReviewerEn,
          readingTime: _readingTime,
          contentBn: _contentBn,
          contentEn: _contentEn,
          onReviewedChanged: (val) =>
              setState(() => _isMedicallyReviewed = val),
        ),
        const SizedBox(height: 16),
        ArticleEditorMediaSection(
          imagePath: _imagePath,
          audioBn: _audioBn,
          audioEn: _audioEn,
          onImageChanged: (ImagePick? pick) {
            setState(() {
              _pickedImage = pick;
              if (pick != null) {
                _removedImage = false;
                _imagePath = pick.path ?? _imagePath;
              } else {
                _removedImage = widget.article.imagePath.isNotEmpty;
                _imagePath = null;
              }
            });
          },
          onAudioBnChanged: (AudioPick? pick) {
            setState(() {
              _pickedAudioBn = pick;
              if (pick != null) {
                _removedAudioBn = false;
              } else {
                _removedAudioBn =
                    widget.article.audioBnPath?.isNotEmpty ?? false;
                _audioBn = null;
              }
            });
          },
          onAudioEnChanged: (AudioPick? pick) {
            setState(() {
              _pickedAudioEn = pick;
              if (pick != null) {
                _removedAudioEn = false;
              } else {
                _removedAudioEn =
                    widget.article.audioEnPath?.isNotEmpty ?? false;
                _audioEn = null;
              }
            });
          },
        ),
      ],
    );

    final settingsSidebar = ArticleEditorSettingsSidebar(
      categoryId: _categoryId,
      status: _status,
      featured: _featured,
      tags: _tags,
      tagInput: _tagInput,
      slug: _slug,
      seoTitle: _seoTitle,
      seoDesc: _seoDesc,
      order: _order,
      isNew: widget.isNew,
      onCategoryChanged: (id) => setState(() => _categoryId = id),
      onStatusChanged: (s) => setState(() => _status = s),
      onFeaturedChanged: (f) => setState(() => _featured = f),
      onAddTag: (t) => setState(() => _tags.add(t)),
      onRemoveTag: (t) => setState(() => _tags.remove(t)),
      onSave: _save,
      onCancel: _handleCancel,
    );

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleCancel();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _handleCancel,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isNew ? 'New Article' : 'Edit Article',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Obx(
                      () => controller.isSaving.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (desktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: contentSection),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: settingsSidebar),
                    ],
                  )
                else
                  Column(
                    children: [
                      contentSection,
                      const SizedBox(height: 16),
                      settingsSidebar,
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
