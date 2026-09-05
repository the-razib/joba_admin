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
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final articles = controller.popularArticles;
        if (articles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No published articles yet',
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final a in articles)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ArticleThumb(
                          imagePath: a.imagePath,
                          width: 44,
                          height: 44,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            const SizedBox(height: 2),
                            Text(
                              a.titleEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.palette.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                                  fontSize: 11,
                                  color: context.palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
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
                                  fontSize: 11,
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
              ),
          ],
        );
      }),
    );
  }
}
