import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';
import 'package:joba_admin/features/articles/views/widgets/add_article_category_dialog.dart';

/// Category manager, mobile preview & tag library (Articles › Categories & Tags tab).
class CategoriesTagsView extends GetView<ArticlesController> {
  const CategoriesTagsView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesCard(context);
    final mobilePreview = _mobileSelfCarePreviewCard(context);
    final tags = _tagsCard(context);

    return Responsive.isDesktop(context)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: categories,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      mobilePreview,
                      const SizedBox(height: 14),
                      tags,
                    ],
                  ),
                ),
              ),
            ],
          )
        : ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              categories,
              const SizedBox(height: 14),
              mobilePreview,
              const SizedBox(height: 14),
              tags,
            ],
          );
  }

  Widget _categoriesCard(BuildContext context) {
    final palette = context.palette;
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Article Categories & Topics',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Categories configure the mobile app\'s "নিজের যত্ন" (Self-Care) topics and orientation.',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  ElevatedButton.icon(
                    onPressed: () => AddArticleCategoryDialog.show(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: [
                  for (final c in controller.categories)
                    _CategoryRowItem(
                      category: c,
                      articleCount: controller.countFor(c.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileSelfCarePreviewCard(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone_iphone,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile App Preview (নিজের যত্ন)',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Live simulation of the 1:1 mobile self-care orientation',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone Container Mockup
            Center(
              child: Container(
                width: 290,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F5), // Mobile homeScaffoldBg
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2DCD5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Phone Top Bar / Notch simulation
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '11:40',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.wifi, size: 11),
                              SizedBox(width: 4),
                              Icon(Icons.battery_full, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Mobile App Title "নিজের যত্ন"
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'নিজের যত্ন',
                        style: AppTheme.bengali(context).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2523),
                        ),
                      ),
                    ),

                    // Dynamic Category Cards Preview
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Obx(() {
                        final cats = controller.categories.where((c) => c.active).toList();
                        return Column(
                          children: _buildMobileCardsLayout(context, cats),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMobileCardsLayout(BuildContext context, List<ArticleCategory> cats) {
    final widgets = <Widget>[];
    int i = 0;
    while (i < cats.length) {
      final current = cats[i];
      if (current.isFullWidth || i == cats.length - 1) {
        // Full width card
        widgets.add(_buildPhotoCard(
          context,
          title: current.nameBn,
          subtitle: current.subtitleBn.isNotEmpty ? current.subtitleBn : current.nameEn,
          imagePath: current.imagePath,
          height: 95,
        ));
        widgets.add(const SizedBox(height: 8));
        i++;
      } else {
        // Two half width cards side by side
        final next = cats[i + 1];
        widgets.add(
          Row(
            children: [
              Expanded(
                child: _buildPhotoCard(
                  context,
                  title: current.nameBn,
                  subtitle: current.subtitleBn.isNotEmpty ? current.subtitleBn : current.nameEn,
                  imagePath: current.imagePath,
                  height: 92,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhotoCard(
                  context,
                  title: next.nameBn,
                  subtitle: next.subtitleBn.isNotEmpty ? next.subtitleBn : next.nameEn,
                  imagePath: next.imagePath,
                  height: 92,
                ),
              ),
            ],
          ),
        );
        widgets.add(const SizedBox(height: 8));
        i += 2;
      }
    }
    return widgets;
  }

  Widget _buildPhotoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required double height,
  }) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Photo
          _buildCardImage(imagePath),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Bottom Left Title & Subtitle
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bengali(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bengali(context).copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardImage(String path) {
    if (path.isEmpty) {
      return Container(color: const Color(0xFFC0A89A));
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFC0A89A)),
    );
  }

  Widget _tagsCard(BuildContext context) {
    final palette = context.palette;
    final tagCtrl = TextEditingController();
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
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
              'Tags used across articles for search & filtering in the app.',
              style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
            ),
            if (canManage) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tagCtrl,
                      decoration: const InputDecoration(
                        hintText: 'New tag name...',
                        isDense: true,
                      ),
                      onSubmitted: (v) {
                        controller.addTag(v);
                        tagCtrl.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      controller.addTag(tagCtrl.text);
                      tagCtrl.clear();
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in controller.tags)
                    Chip(
                      label: Text(t),
                      deleteIcon: canManage ? const Icon(Icons.close, size: 14) : null,
                      onDeleted: canManage ? () => controller.removeTag(t) : null,
                      backgroundColor: palette.inputFill,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRowItem extends StatelessWidget {
  final ArticleCategory category;
  final int articleCount;

  const _CategoryRowItem({
    required this.category,
    required this.articleCount,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticlesController>();
    final palette = context.palette;
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: palette.border,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Category Photo Thumbnail
          Container(
            width: 48,
            height: 38,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
            ),
            child: category.imagePath.isNotEmpty
                ? Image.asset(
                    category.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.image, size: 16, color: AppColors.primary),
                    ),
                  )
                : Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.image, size: 16, color: AppColors.primary),
                  ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category.nameBn,
                      style: AppTheme.bengali(context).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${category.nameEn})',
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: category.isFullWidth
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category.isFullWidth ? 'Full Width' : 'Half Grid',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: category.isFullWidth ? AppColors.primary : AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                if (category.subtitleBn.isNotEmpty || category.subtitleEn.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${category.subtitleBn}  •  ${category.subtitleEn}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Article Count Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$articleCount articles',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (canManage) ...[
            const SizedBox(width: 10),

            // Edit Category Button
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: 'Edit Category',
              onPressed: () => AddArticleCategoryDialog.show(context, category: category),
            ),

            // Active Switch
            Switch(
              value: category.active,
              activeTrackColor: AppColors.primary,
              onChanged: (_) => controller.toggleCategory(category.id),
            ),
          ],
        ],
      ),
    );
  }
}
