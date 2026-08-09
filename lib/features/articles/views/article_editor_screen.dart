import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:joba_admin/core/models/article.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/audio_upload_field.dart';
import 'package:joba_admin/core/widgets/bilingual_text_field.dart';
import 'package:joba_admin/core/widgets/image_upload_field.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';

/// Bilingual article editor: BN + EN titles/subtitles/content, thumbnail,
/// per-language audio uploads, tags, publishing and SEO settings.
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

  late String _categoryId;
  late ArticleStatus _status;
  late bool _featured;
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
    _categoryId = a.categoryId;
    _status = a.status;
    _featured = a.featured;
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
    final saved = widget.article.copyWith(
      categoryId: _categoryId,
      titleBn: _titleBn.text.trim(),
      titleEn: _titleEn.text.trim(),
      subtitleBn: _subBn.text.trim(),
      subtitleEn: _subEn.text.trim(),
      contentBn: _contentBn.text.trim(),
      contentEn: _contentEn.text.trim(),
      imagePath: _imagePath ?? '',
      audioBnPath: _audioBn,
      audioEnPath: _audioEn,
      tags: _tags,
      status: _status,
      featured: _featured,
      displayOrder: int.tryParse(_order.text) ?? widget.article.displayOrder,
      slug: _slug.text.trim(),
      seoTitle: _seoTitle.text.trim(),
      seoDescription: _seoDesc.text.trim(),
    );
    controller.saveArticle(saved);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final desktop = Responsive.isDesktop(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: palette.card,
            border: Border(bottom: BorderSide(color: palette.border)),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.closeEditor,
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isNew ? 'New Article' : 'Edit Article',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Content is published to the app in both languages.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.closeEditor,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save Article'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _contentCard(context)),
                          const SizedBox(width: 16),
                          Expanded(flex: 3, child: _sideColumn(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _contentCard(context),
                          const SizedBox(height: 16),
                          _sideColumn(context),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _contentCard(BuildContext context) {
    final palette = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle(context, 'Content — বাংলা + English'),
            const SizedBox(height: 16),
            BilingualField(
              label: 'Title *',
              bnController: _titleBn,
              enController: _titleEn,
              hintEn: 'Article title',
            ),
            const SizedBox(height: 16),
            BilingualField(
              label: 'Short description / subtitle',
              bnController: _subBn,
              enController: _subEn,
              maxLines: 2,
              hintEn: 'One-line summary shown in lists',
            ),
            const SizedBox(height: 16),
            BilingualField(
              label: 'Full content',
              bnController: _contentBn,
              enController: _contentEn,
              maxLines: 8,
              hintEn: 'Article body…',
            ),
            const SizedBox(height: 18),
            Text(
              'Tags',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _tags)
                  Chip(
                    label: Text('#$t', style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _tags.remove(t)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagInput,
                    decoration: const InputDecoration(
                      hintText: 'Add tag (e.g. cramps)',
                      isDense: true,
                    ),
                    onSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _addTag(_tagInput.text),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTag(String v) {
    final t = v.trim().toLowerCase();
    if (t.isEmpty) return;
    setState(() {
      if (!_tags.contains(t)) _tags.add(t);
      _tagInput.clear();
    });
  }

  Widget _sideColumn(BuildContext context) {
    return Column(
      children: [
        _publishCard(context),
        const SizedBox(height: 16),
        _mediaCard(context),
        const SizedBox(height: 16),
        _seoCard(context),
      ],
    );
  }

  Widget _publishCard(BuildContext context) {
    final palette = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle(context, 'Publishing'),
            const SizedBox(height: 14),
            Text(
              'Category',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: _categoryId,
                isExpanded: true,
                items: [
                  for (final c in controller.categories)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        '${c.nameEn} (${c.nameBn})',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _categoryId = v!),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Status',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<ArticleStatus>(
              initialValue: _status,
              isExpanded: true,
              items: [
                for (final s in ArticleStatus.values)
                  DropdownMenuItem(
                    value: s,
                    child: Text(s.name, style: const TextStyle(fontSize: 13)),
                  ),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _featured,
              activeThumbColor: AppColors.primary,
              title: Text(
                'Featured article',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Shown on the app home screen.',
                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
              ),
              onChanged: (v) => setState(() => _featured = v),
            ),
            TextField(
              controller: _order,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Display order',
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle(context, 'Media'),
            const SizedBox(height: 14),
            ImageUploadField(
              label: 'Thumbnail',
              currentPath: _imagePath,
              height: 130,
              onChanged: (pick) => setState(
                () => _imagePath = pick?.path ?? 'mock://uploaded-thumb.png',
              ),
            ),
            const SizedBox(height: 14),
            AudioUploadField(
              label: 'Audio — বাংলা (BN)',
              currentPath: _audioBn,
              onChanged: (pick) => setState(
                () => _audioBn = pick != null ? 'mock://${pick.name}' : null,
              ),
            ),
            const SizedBox(height: 10),
            AudioUploadField(
              label: 'Audio — English (EN)',
              currentPath: _audioEn,
              onChanged: (pick) => setState(
                () => _audioEn = pick != null ? 'mock://${pick.name}' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seoCard(BuildContext context) {
    final palette = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle(context, 'SEO & Meta'),
            const SizedBox(height: 14),
            TextField(
              controller: _slug,
              decoration: const InputDecoration(
                labelText: 'Slug',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _seoTitle,
              decoration: const InputDecoration(
                labelText: 'SEO title',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _seoDesc,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'SEO description',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Slug and SEO fields are admin-only; the app ignores them.',
              style: TextStyle(color: palette.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardTitle(BuildContext context, String t) => Text(
    t,
    style: TextStyle(
      color: context.palette.textPrimary,
      fontSize: 14.5,
      fontWeight: FontWeight.w700,
    ),
  );
}
