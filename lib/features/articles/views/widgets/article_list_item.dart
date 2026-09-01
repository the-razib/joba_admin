import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/article_thumb.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/views/widgets/article_details_body.dart';

/// Single item in the articles reorderable list view with responsive mobile adaptation.
class ArticleListItem extends GetView<ArticlesController> {
  const ArticleListItem({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final a = article;
      final selected = controller.selectedArticleId.value == a.id;
      final mobile = Responsive.isMobile(context);

      return InkWell(
        onTap: () {
          controller.selectArticle(a.id);
          if (mobile) {
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
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 8 : 12,
            vertical: 10,
          ),
          child: Row(
            children: [
              ArticleThumb(
                imagePath: a.imagePath,
                width: mobile ? 48 : 62,
                height: mobile ? 40 : 50,
              ),
              const SizedBox(width: 8),
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bookmark_outline_rounded,
                              size: 12,
                              color: context.palette.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              compactNumber(a.bookmarks),
                              style: TextStyle(
                                fontSize: 10.5,
                                color: context.palette.textSecondary,
                              ),
                            ),
                          ],
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
    });
  }
}
