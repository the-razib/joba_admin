import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

/// Article thumbnail: asset/url image, or a branded gradient placeholder.
class ArticleThumb extends StatelessWidget {
  const ArticleThumb({
    super.key,
    required this.imagePath,
    this.width = 72,
    this.height = 56,
    this.radius = 10,
  });

  final String imagePath;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (imagePath.isEmpty) {
      child = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDE8EE), Color(0xFFE3F3EB)],
          ),
        ),
        child: const Icon(Icons.local_florist_rounded,
            color: AppColors.accent, size: 22),
      );
    } else if (imagePath.startsWith('http')) {
      child = Image.network(imagePath, fit: BoxFit.cover);
    } else {
      child = Image.asset(imagePath, fit: BoxFit.cover);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}
