import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/article_thumb.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

/// Card displaying the list of top-performing health & education articles.
class DashboardPopularArticlesCard extends GetView<DashboardController> {
  const DashboardPopularArticlesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();

    return SectionCard(
      title: 'Popular Articles',
      action: 'View All',
      onAction: () => shell.select(NavId.articles),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          for (final a in controller.popularArticles)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  ArticleThumb(
                    imagePath: a.imagePath,
                    width: 56,
                    height: 46,
                  ),
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 13,
                              color: context.palette.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              compactNumber(a.views),
                              style: TextStyle(
                                fontSize: 11,
                                color: context.palette.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.bookmark_outline_rounded,
                              size: 13,
                              color: context.palette.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              compactNumber(a.bookmarks),
                              style: TextStyle(
                                fontSize: 11,
                                color: context.palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
