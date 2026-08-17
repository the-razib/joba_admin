import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/views/widgets/add_article_category_dialog.dart';

/// Categories navigation pane on desktop workspace view.
class ArticlesCategoryPane extends GetView<ArticlesController> {
  const ArticlesCategoryPane({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => AddArticleCategoryDialog.show(context),
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Add', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: palette.border),
          Expanded(
            child: Obx(
              () => ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  for (final c in controller.categories)
                    _CategoryTile(category: c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends GetView<ArticlesController> {
  const _CategoryTile({required this.category});

  final ArticleCategory category;

  @override
  Widget build(BuildContext context) {
    final c = category;

    return Obx(() {
      final selected = controller.selectedCategoryId.value == c.id;

      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => controller.selectCategory(c.id),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.folder_open : Icons.folder_outlined,
                size: 18,
                color: selected
                    ? AppColors.accent
                    : context.palette.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nameEn,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    Text(
                      c.nameBn,
                      style: AppTheme.bengali(
                        context,
                        fontSize: 11,
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${controller.countFor(c.id)}',
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
