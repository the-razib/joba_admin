import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/article.dart';
import 'package:joba_admin/core/models/article_category.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/article_thumb.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/core/widgets/empty_state.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/views/article_editor_screen.dart';
import 'package:joba_admin/features/articles/views/categories_tags_view.dart';

class ArticlesScreen extends GetView<ArticlesController> {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final editing = controller.editing.value;
      if (editing != null) {
        return ArticleEditorScreen(
          article: editing,
          isNew: controller.editingIsNew.value,
        );
      }
      return Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Column(
          children: [
            _workspaceHeader(context),
            const SizedBox(height: 14),
            Expanded(
              child: Obx(
                () => controller.tab.value == 1
                    ? const CategoriesTagsView()
                    : _workspace(context),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _workspaceHeader(BuildContext context) {
    return Row(
      children: [
        _TabToggle(
          labels: const ['Articles', 'Categories & Tags'],
          selected: controller.tab.value,
          onSelected: (i) => controller.tab.value = i,
        ),
        const Spacer(),
        if (controller.tab.value == 0)
          ElevatedButton.icon(
            onPressed: controller.startAdd,
            icon: const Icon(Icons.add, size: 17),
            label: Responsive.isMobile(context)
                ? const SizedBox()
                : const Text('Add Article'),
          ),
      ],
    );
  }

  Widget _workspace(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 250, child: _CategoriesPane()),
          const SizedBox(width: 14),
          const SizedBox(width: 370, child: _ListPane()),
          const SizedBox(width: 14),
          const Expanded(child: _DetailsPane()),
        ],
      );
    }
    if (Responsive.isTablet(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 380, child: _ListPane(withCategoryChips: true)),
          const SizedBox(width: 14),
          const Expanded(child: _DetailsPane()),
        ],
      );
    }
    return const _ListPane(withCategoryChips: true);
  }
}

class _TabToggle extends StatelessWidget {
  const _TabToggle({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.palette.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected == i
                      ? context.palette.card
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected == i
                        ? AppColors.primary
                        : context.palette.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- categories

class _CategoriesPane extends GetView<ArticlesController> {
  const _CategoriesPane();

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
                  onPressed: () => _addCategoryDialog(context),
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
                    _categoryTile(context, c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(BuildContext context, ArticleCategory c) {
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
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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
  }

  void _addCategoryDialog(BuildContext context) {
    final bn = TextEditingController();
    final en = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Category',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: bn,
                  style: AppTheme.bengali(context),
                  decoration: const InputDecoration(hintText: 'নাম (বাংলা)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: en,
                  decoration: const InputDecoration(hintText: 'Name (English)'),
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
                        if (bn.text.trim().isEmpty || en.text.trim().isEmpty) {
                          return;
                        }
                        controller.addCategory(
                          nameBn: bn.text.trim(),
                          nameEn: en.text.trim(),
                        );
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

// ---------------------------------------------------------------- list pane

class _ListPane extends GetView<ArticlesController> {
  const _ListPane({this.withCategoryChips = false});

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
                  SizedBox(
                    height: 34,
                    child: Obx(
                      () => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final c = controller.categories[i];
                          final sel =
                              controller.selectedCategoryId.value == c.id;
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
                  ),
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
                buildDefaultDragHandles: true,
                onReorder: controller.reorderArticles,
                itemBuilder: (_, i) =>
                    _articleRow(context, list[i], key: ValueKey(list[i].id)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _articleRow(BuildContext context, Article a, {required Key key}) {
    final selected = controller.selectedArticleId.value == a.id;
    return InkWell(
      key: key,
      onTap: () {
        controller.selectArticle(a.id);
        if (Responsive.isMobile(context)) {
          showDetailPanel(
            context,
            title: 'Article Details',
            width: 520,
            child: ArticleDetailsBody(article: a),
          );
        }
      },
      child: Container(
        color: selected ? AppColors.accent.withValues(alpha: 0.07) : null,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ArticleThumb(imagePath: a.imagePath, width: 62, height: 50),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.titleBn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bengali(
                      context,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    a.titleEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 12,
                        color: context.palette.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        compactNumber(a.views),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: context.palette.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.favorite_outline,
                        size: 12,
                        color: context.palette.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          compactNumber(a.likes),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            articleStatusBadge(a.status),
            const SizedBox(width: 4),
            Icon(
              Icons.drag_handle,
              size: 18,
              color: context.palette.textSecondary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- details

class _DetailsPane extends GetView<ArticlesController> {
  const _DetailsPane();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final a = controller.selectedArticle;
      if (a == null) {
        return const Card(
          child: EmptyState(
            icon: Icons.article_outlined,
            title: 'Select an article',
          ),
        );
      }
      return Card(child: ArticleDetailsBody(article: a));
    });
  }
}

/// Shared between the desktop pane and the mobile detail panel.
class ArticleDetailsBody extends GetView<ArticlesController> {
  const ArticleDetailsBody({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) => _DetailsContent(article: article);
}

class _DetailsContent extends StatefulWidget {
  const _DetailsContent({required this.article});

  final Article article;

  @override
  State<_DetailsContent> createState() => _DetailsContentState();
}

class _DetailsContentState extends State<_DetailsContent> {
  int _tab = 0;
  bool _bnReader = true;

  Article get a => widget.article;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final controller = Get.find<ArticlesController>();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArticleThumb(
                      imagePath: a.imagePath,
                      width: 108,
                      height: 84,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.titleBn,
                            style: AppTheme.bengali(
                              context,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a.titleEn,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              articleStatusBadge(a.status),
                              if (a.featured)
                                const PillBadge(
                                  label: 'Featured',
                                  color: AppColors.warning,
                                  icon: Icons.star,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _metaRow(context, 'Slug', a.slug, copyable: true),
                _metaRow(
                  context,
                  'Category',
                  controller.categories
                          .firstWhereOrNull((c) => c.id == a.categoryId)
                          ?.nameEn ??
                      a.categoryId,
                ),
                _metaRow(context, 'Tags', a.tags.join(', ')),
                _metaRow(context, 'Updated', formatDateTime(a.updatedAt)),
                const SizedBox(height: 14),
                _tabRow(context),
                const SizedBox(height: 16),
                if (_tab == 0) _contentTab(context),
                if (_tab == 1) _seoMediaTab(context),
                if (_tab == 2) _statsTab(context),
                if (_tab == 3) _historyTab(context),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Danger Zone',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Delete this article permanently. This action cannot be undone.',
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                        ),
                        onPressed: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'Delete article?',
                            message:
                                '"${a.titleEn}" will be removed for all users.',
                            confirmLabel: 'Delete',
                            danger: true,
                          );
                          if (ok) await controller.deleteArticle(a.id);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showReader(context),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Preview'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.startEdit(a),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Article'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metaRow(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
  }) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Copy slug',
              icon: const Icon(Icons.copy_outlined, size: 15),
              onPressed: () => Clipboard.setData(ClipboardData(text: value)),
            ),
        ],
      ),
    );
  }

  Widget _tabRow(BuildContext context) {
    const tabs = ['Content', 'SEO & Media', 'Stats', 'History'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            InkWell(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _tab == i ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: _tab == i
                        ? AppColors.primary
                        : context.palette.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }

  Widget _contentTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Short Description',
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          a.subtitleBn,
          style: AppTheme.bengali(
            context,
            fontSize: 13,
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Content',
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          a.contentBn,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.bengali(
            context,
            fontSize: 13,
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _showReader(context),
          child: const Text('View Full Content'),
        ),
      ],
    );
  }

  Widget _seoMediaTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metaRow(context, 'SEO title', a.seoTitle),
        _metaRow(context, 'SEO desc', a.seoDescription),
        const SizedBox(height: 8),
        Text(
          'Media',
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _audioRow(context, 'Audio — বাংলা', a.audioBnPath),
        const SizedBox(height: 8),
        _audioRow(context, 'Audio — English', a.audioEnPath),
      ],
    );
  }

  Widget _audioRow(BuildContext context, String label, String? path) {
    final has = path != null && path.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.palette.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.audiotrack,
            size: 17,
            color: has ? AppColors.purple : context.palette.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              has ? label : '$label — not uploaded',
              style: TextStyle(
                color: has
                    ? context.palette.textPrimary
                    : context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          if (has)
            const Icon(
              Icons.play_circle_outline,
              size: 18,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _statsTab(BuildContext context) {
    final tiles = [
      (Icons.visibility_outlined, 'Total Views', a.views, AppColors.primary),
      (Icons.favorite_outline, 'Likes', a.likes, AppColors.accent),
      (
        Icons.chat_bubble_outline,
        'Comments',
        a.commentsCount,
        AppColors.warning,
      ),
      (Icons.share_outlined, 'Shares', a.shares, AppColors.info),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 92,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: tiles.length,
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tiles[i].$4.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(tiles[i].$1, color: tiles[i].$4, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  compactNumber(tiles[i].$3),
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tiles[i].$2,
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyTab(BuildContext context) {
    return Column(
      children: [
        for (var v = a.version; v >= 1; v--)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v == a.version
                            ? 'Current version (v$v)'
                            : 'Version v$v',
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${formatDateTime(a.updatedAt.subtract(Duration(days: (a.version - v) * 9)))} • by ${a.createdBy}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showReader(BuildContext context) {
    setState(() => _bnReader = true);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _bnReader ? a.titleBn : a.titleEn,
                          style: _bnReader
                              ? AppTheme.bengali(
                                  context,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                )
                              : TextStyle(
                                  color: context.palette.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (final bn in [true, false])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: _bnReader == bn,
                            label: Text(
                              bn ? 'বাংলা' : 'English',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onSelected: (_) => setState(() => _bnReader = bn),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        _bnReader ? a.contentBn : a.contentEn,
                        style: _bnReader
                            ? AppTheme.bengali(
                                context,
                                fontSize: 14,
                                color: context.palette.textPrimary,
                              )
                            : TextStyle(
                                color: context.palette.textPrimary,
                                fontSize: 14,
                                height: 1.7,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
