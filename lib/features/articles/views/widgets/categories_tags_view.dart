import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/views/widgets/add_article_category_dialog.dart';

/// Category manager + tag library (Articles › Categories & Tags tab).
class CategoriesTagsView extends GetView<ArticlesController> {
  const CategoriesTagsView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesCard(context);
    final tags = _tagsCard(context);

    return Responsive.isDesktop(context)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: categories),
              const SizedBox(width: 14),
              Expanded(flex: 2, child: tags),
            ],
          )
        : ListView(
            children: [categories, const SizedBox(height: 14), tags],
          );
  }

  Widget _categoriesCard(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Article Categories',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => AddArticleCategoryDialog.show(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Category'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Category IDs map to the app\'s TopicType (period, care, menopause, discharge, myths).',
              style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
            ),
            const SizedBox(height: 14),
            Obx(
              () => Column(
                children: [
                  for (final c in controller.categories)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: palette.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 18,
                            color: c.active
                                ? AppColors.accent
                                : palette.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${c.nameEn}  •  ${c.id}',
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  c.nameBn,
                                  style: AppTheme.bengali(
                                    context,
                                    fontSize: 11.5,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${controller.countFor(c.id)} articles',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagsCard(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tags Library',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _addTagDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Tag'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Keywords used across articles for discovery.',
              style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
            ),
            const SizedBox(height: 14),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in controller.tags)
                    Chip(
                      label: Text(t, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => controller.removeTag(t),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTagDialog(BuildContext context) {
    final text = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Tag',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: text,
                  decoration: const InputDecoration(
                    hintText: 'Tag name (e.g. nutrition)',
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final val = text.text.trim();
                        if (val.isEmpty) return;
                        controller.addTag(val);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add'),
                    ),
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
