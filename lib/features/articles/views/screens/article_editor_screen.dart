import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/views/widgets/article_editor_bilingual_section.dart';
import 'package:joba_admin/features/articles/views/widgets/article_editor_media_section.dart';
import 'package:joba_admin/features/articles/views/widgets/article_editor_medical_section.dart';
import 'package:joba_admin/features/articles/views/widgets/article_editor_settings_sidebar.dart';

/// Bilingual article editor screen: BN + EN titles/subtitles/content, thumbnail,
/// per-language audio uploads, medical reviewer verification, tags, publishing and SEO settings.
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
    _readingTime = TextEditingController(text: '${a.readingTimeMin}');
    _categoryId = a.categoryId;
    _status = a.status;
    _featured = a.featured;
    _isMedicallyReviewed = a.isMedicallyReviewed;
    _tags = List.of(a.tags);
    _imagePath = a.imagePath.isEmpty ? null : a.imagePath;
    _audioBn = a.audioBnPath;
    _audioEn = a.audioEnPath;
  }

  @override
  void dispose() {
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

  void _save() {
    if (_titleBn.text.trim().isEmpty || _titleEn.text.trim().isEmpty) {
      Get.snackbar(
        'Missing titles',
        'Both বাংলা and English titles are required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final orderVal = int.tryParse(_order.text.trim()) ?? 0;
    final readingTimeVal = int.tryParse(_readingTime.text.trim()) ?? 3;
    final updated = widget.article.copyWith(
      titleBn: _titleBn.text.trim(),
      titleEn: _titleEn.text.trim(),
      subtitleBn: _subBn.text.trim(),
      subtitleEn: _subEn.text.trim(),
      contentBn: _contentBn.text.trim(),
      contentEn: _contentEn.text.trim(),
      categoryId: _categoryId,
      status: _status,
      featured: _featured,
      displayOrder: orderVal,
      readingTimeMin: readingTimeVal,
      medicalReviewerBn: _medicalReviewerBn.text.trim(),
      medicalReviewerEn: _medicalReviewerEn.text.trim(),
      isMedicallyReviewed: _isMedicallyReviewed,
      tags: _tags,
      imagePath: _imagePath ?? '',
      audioBnPath: _audioBn,
      audioEnPath: _audioEn,
      slug: _slug.text.trim(),
      seoTitle: _seoTitle.text.trim(),
      seoDescription: _seoDesc.text.trim(),
    );
    controller.saveArticle(updated);
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
          onReviewedChanged: (val) => setState(() => _isMedicallyReviewed = val),
        ),
        const SizedBox(height: 16),
        ArticleEditorMediaSection(
          imagePath: _imagePath,
          audioBn: _audioBn,
          audioEn: _audioEn,
          onImageChanged: (p) => setState(() => _imagePath = p),
          onAudioBnChanged: (p) => setState(() => _audioBn = p),
          onAudioEnChanged: (p) => setState(() => _audioEn = p),
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
      onCancel: controller.closeEditor,
    );

    return SingleChildScrollView(
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
                    onPressed: controller.closeEditor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isNew ? 'New Article' : 'Edit Article',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
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
    );
  }
}
