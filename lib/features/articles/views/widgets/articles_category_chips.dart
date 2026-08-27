import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';

/// Horizontal list of category FilterChips for tablet/mobile article workspaces.
class ArticlesCategoryChips extends GetView<ArticlesController> {
  const ArticlesCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final selectedId = controller.selectedCategoryId.value;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in controller.categories) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    key: ValueKey(c.id),
                    selected: selectedId == c.id,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(
                      c.nameEn,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onSelected: (_) => controller.selectCategory(c.id),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
