import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';

/// Horizontal list of category FilterChips for tablet/mobile article workspaces.
class ArticlesCategoryChips extends GetView<ArticlesController> {
  const ArticlesCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = controller.categories[i];
            final sel = controller.selectedCategoryId.value == c.id;
            return FilterChip(
              selected: sel,
              label: Text(
                c.nameEn,
                style: const TextStyle(fontSize: 12),
              ),
              onSelected: (_) => controller.selectCategory(c.id),
            );
          },
        ),
      ),
    );
  }
}
