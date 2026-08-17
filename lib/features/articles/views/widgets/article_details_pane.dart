import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/widgets/empty_state.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/views/widgets/article_details_body.dart';

/// Card container displaying the details of the selected article on desktop.
class ArticleDetailsPane extends GetView<ArticlesController> {
  const ArticleDetailsPane({super.key});

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
