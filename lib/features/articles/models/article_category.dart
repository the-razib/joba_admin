/// Mirrors the app's `article_categories` collection.
/// `id` matches the app's TopicType names where they exist
/// (period, menopause, care, discharge, myths).
class ArticleCategory {
  const ArticleCategory({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.order,
    this.active = true,
  });

  final String id;
  final String nameBn;
  final String nameEn;
  final int order;
  final bool active;

  ArticleCategory copyWith({
    String? nameBn,
    String? nameEn,
    int? order,
    bool? active,
  }) =>
      ArticleCategory(
        id: id,
        nameBn: nameBn ?? this.nameBn,
        nameEn: nameEn ?? this.nameEn,
        order: order ?? this.order,
        active: active ?? this.active,
      );
}
