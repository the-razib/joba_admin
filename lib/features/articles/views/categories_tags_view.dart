import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';

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
        : ListView(children: [categories, const SizedBox(height: 14), tags]);
  }

  Widget _categoriesCard(BuildContext context) {
    final palette = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Article Categories',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
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
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: c.active,
                            activeThumbColor: AppColors.primary,
                            onChanged: (_) => controller.toggleCategory(c.id),
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
    final tagInput = TextEditingController();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tag Library',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tags help users discover related articles in the app.',
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
                      label: Text('#$t', style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => controller.removeTag(t),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
                      controller.addTag(v);
                      tagInput.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    controller.addTag(tagInput.text);
                    tagInput.clear();
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
