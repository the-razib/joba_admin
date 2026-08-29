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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': {'bn': nameBn, 'en': nameEn},
      'nameBn': nameBn,
      'nameEn': nameEn,
      'subtitle': {'bn': subtitleBn, 'en': subtitleEn},
      'subtitleBn': subtitleBn,
      'subtitleEn': subtitleEn,
      'imagePath': imagePath,
      'imageUrl': imagePath,
      'isFullWidth': isFullWidth,
      'order': order,
      'active': active,
    };
  }

  factory ArticleCategory.fromMap(Map<String, dynamic> map, {String? docId}) {
    final nameMap = map['name'] as Map<String, dynamic>?;
    final subtitleMap = map['subtitle'] as Map<String, dynamic>?;

    return ArticleCategory(
      id: docId ?? map['id']?.toString() ?? '',
      nameBn: nameMap?['bn']?.toString() ?? map['nameBn']?.toString() ?? '',
      nameEn: nameMap?['en']?.toString() ?? map['nameEn']?.toString() ?? '',
      subtitleBn: subtitleMap?['bn']?.toString() ?? map['subtitleBn']?.toString() ?? '',
      subtitleEn: subtitleMap?['en']?.toString() ?? map['subtitleEn']?.toString() ?? '',
      imagePath: map['imageUrl']?.toString() ?? map['imagePath']?.toString() ?? '',
      isFullWidth: map['isFullWidth'] as bool? ?? false,
      order: (map['order'] as num?)?.toInt() ?? 0,
      active: map['active'] as bool? ?? true,
    );
  }
}
