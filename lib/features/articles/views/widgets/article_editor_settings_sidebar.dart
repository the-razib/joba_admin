import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';

/// Settings and publishing sidebar for the Article Editor.
class ArticleEditorSettingsSidebar extends StatelessWidget {
  const ArticleEditorSettingsSidebar({
    super.key,
    required this.categoryId,
    required this.status,
    required this.featured,
    required this.tags,
    required this.tagInput,
    required this.slug,
    required this.seoTitle,
    required this.seoDesc,
    required this.order,
    required this.isNew,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onFeaturedChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSave,
    required this.onCancel,
  });

  final String categoryId;
  final ArticleStatus status;
  final bool featured;
  final List<String> tags;
  final TextEditingController tagInput;
  final TextEditingController slug;
  final TextEditingController seoTitle;
  final TextEditingController seoDesc;
  final TextEditingController order;
  final bool isNew;

  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<ArticleStatus> onStatusChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final controller = Get.find<ArticlesController>();

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Publishing',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _fieldLabel(context, 'Status'),
                DropdownButtonFormField<ArticleStatus>(
                  initialValue: status,
                  decoration: const InputDecoration(isDense: true),
                  items: [
                    for (final s in ArticleStatus.values)
                      DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) onStatusChanged(v);
                  },
                ),
                const SizedBox(height: 14),
                _fieldLabel(context, 'Category'),
                DropdownButtonFormField<String>(
                  initialValue: categoryId,
                  decoration: const InputDecoration(isDense: true),
                  items: [
                    for (final c in controller.categories)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.nameEn} (${c.nameBn})'),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) onCategoryChanged(v);
                  },
                ),
                const SizedBox(height: 14),
                _fieldLabel(context, 'Display Order'),
                TextField(
                  controller: order,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: '0, 1, 2...',
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Featured Article',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    'Pins this article to the top of home carousel',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  value: featured,
                  activeThumbColor: AppColors.primary,
                  onChanged: onFeaturedChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tags',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in tags)
                      Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => onRemoveTag(t),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tagInput,
                        decoration: const InputDecoration(
                          hintText: 'Add a tag...',
                          isDense: true,
                        ),
                        onSubmitted: (v) {
                          final trimmed = v.trim();
                          if (trimmed.isNotEmpty) {
                            onAddTag(trimmed);
                            tagInput.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: () {
                        final trimmed = tagInput.text.trim();
                        if (trimmed.isNotEmpty) {
                          onAddTag(trimmed);
                          tagInput.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEO & Metadata',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _fieldLabel(context, 'URL Slug'),
                TextField(
                  controller: slug,
                  decoration: const InputDecoration(
                    hintText: 'e.g. period-pain-relief',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),
                _fieldLabel(context, 'Meta Title'),
                TextField(
                  controller: seoTitle,
                  decoration: const InputDecoration(
                    hintText: 'Search engine display title...',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),
                _fieldLabel(context, 'Meta Description'),
                TextField(
                  controller: seoDesc,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: '150-160 characters for search previews...',
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onSave,
                child: Text(isNew ? 'Publish' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            color: context.palette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
