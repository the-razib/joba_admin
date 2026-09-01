import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/empty_state.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/views/widgets/article_list_item.dart';
import 'package:joba_admin/features/articles/views/widgets/articles_category_chips.dart';

/// Middle pane containing category chips (if needed), search, status filter, and reorderable articles list.
class ArticlesListPane extends GetView<ArticlesController> {
  const ArticlesListPane({super.key, this.withCategoryChips = false});

  final bool withCategoryChips;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (withCategoryChips) ...[
                  const ArticlesCategoryChips(),
                  const SizedBox(height: 10),
                ],
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Articles in ${controller.selectedCategory?.nameEn ?? '—'}',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${controller.filteredArticles.length} articles',
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) => controller.statusFilter.value = v,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: palette.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.statusFilter.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: palette.textPrimary,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 15),
                            ],
                          ),
                        ),
                        itemBuilder: (_) => [
                          for (final s in [
                            'All Status',
                            'Published',
                            'Draft',
                            'Review',
                          ])
                            PopupMenuItem(value: s, child: Text(s)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller.searchController,
                  onChanged: (_) => controller.searchTick.value++,
                  decoration: const InputDecoration(
                    hintText: 'Search articles by title...',
                    isDense: true,
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: palette.border),
          Expanded(
            child: Obx(() {
              controller.searchTick.value; // re-evaluate on search input
              final list = controller.filteredArticles;
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.article_outlined,
                  title: 'No articles here yet',
                  subtitle: 'Use Add Article to create bilingual content.',
                );
              }
              return ReorderableListView.builder(
                itemCount: list.length,
                buildDefaultDragHandles: false,
                onReorder: controller.reorderArticles,
                itemBuilder: (_, i) => ReorderableDelayedDragStartListener(
                  key: ValueKey(list[i].id),
                  index: i,
                  child: ArticleListItem(
                    article: list[i],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
