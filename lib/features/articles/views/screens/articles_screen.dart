import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/views/screens/article_editor_screen.dart';
import 'package:joba_admin/features/articles/views/widgets/article_details_pane.dart';
import 'package:joba_admin/features/articles/views/widgets/articles_category_pane.dart';
import 'package:joba_admin/features/articles/views/widgets/articles_list_pane.dart';
import 'package:joba_admin/features/articles/views/widgets/articles_workspace_header.dart';
import 'package:joba_admin/features/articles/views/widgets/categories_tags_view.dart';

/// Articles Management Screen - Master-detail multi-pane bilingual article workspace.
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
            const ArticlesWorkspaceHeader(),
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

  Widget _workspace(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 250, child: ArticlesCategoryPane()),
          SizedBox(width: 14),
          SizedBox(width: 370, child: ArticlesListPane()),
          SizedBox(width: 14),
          Expanded(child: ArticleDetailsPane()),
        ],
      );
    }
    if (Responsive.isTablet(context)) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 380, child: ArticlesListPane(withCategoryChips: true)),
          SizedBox(width: 14),
          Expanded(child: ArticleDetailsPane()),
        ],
      );
    }
    return const ArticlesListPane(withCategoryChips: true);
  }
}
