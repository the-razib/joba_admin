/// Mirrors the app's `article_categories` collection.
/// `id` matches the app's TopicType names where they exist
/// (period, menopause, care, discharge, myths).
class ArticleCategory {
  const ArticleCategory({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    this.subtitleBn = '',
    this.subtitleEn = '',
    this.imagePath = '',
    this.isFullWidth = false,
    required this.order,
    this.active = true,
  });

  final String id;
  final String nameBn;
  final String nameEn;
  final String subtitleBn;
  final String subtitleEn;
  final String imagePath;
  final bool isFullWidth;
  final int order;
  final bool active;

  ArticleCategory copyWith({
    String? nameBn,
    String? nameEn,
    String? subtitleBn,
    String? subtitleEn,
    String? imagePath,
    bool? isFullWidth,
    int? order,
    bool? active,
  }) =>
      ArticleCategory(
        id: id,
        nameBn: nameBn ?? this.nameBn,
        nameEn: nameEn ?? this.nameEn,
        subtitleBn: subtitleBn ?? this.subtitleBn,
        subtitleEn: subtitleEn ?? this.subtitleEn,
        imagePath: imagePath ?? this.imagePath,
        isFullWidth: isFullWidth ?? this.isFullWidth,
        order: order ?? this.order,
        active: active ?? this.active,
      );
}
