/// Avatar preset category. Seeds match the app's bundled asset folders
/// (modern / simple / animal / hijab); Phase 3 stores these in
/// `avatar_categories` on Firestore.
class AvatarCategory {
  const AvatarCategory({
    required this.id,
    required this.name,
    required this.order,
    this.active = true,
  });

  final String id;
  final String name;
  final int order;
  final bool active;

  AvatarCategory copyWith({String? name, int? order, bool? active}) =>
      AvatarCategory(
        id: id,
        name: name ?? this.name,
        order: order ?? this.order,
        active: active ?? this.active,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'active': active,
    };
  }

  factory AvatarCategory.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AvatarCategory(
      id: docId ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      active: map['active'] as bool? ?? true,
    );
  }
}

class AvatarItem {
  const AvatarItem({
    required this.id,
    required this.categoryId,
    required this.assetPath,
    required this.order,
    this.active = true,
    this.pendingBytes,
  });

  final String id;
  final String categoryId;
  final String assetPath;
  final int order;
  final bool active;

  /// Non-null for freshly picked (not yet "uploaded") avatars.
  final List<int>? pendingBytes;

  String get displayName =>
      id.replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$'), '').replaceAll('_', ' ');

  String get rawName =>
      id.replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$'), '');

  AvatarItem copyWith({bool? active, int? order}) => AvatarItem(
        id: id,
        categoryId: categoryId,
        assetPath: assetPath,
        order: order ?? this.order,
        active: active ?? this.active,
        pendingBytes: pendingBytes,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'assetPath': assetPath,
      'imageUrl': assetPath,
      'order': order,
      'active': active,
    };
  }

  factory AvatarItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AvatarItem(
      id: docId ?? map['id']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? 'modern',
      assetPath: map['imageUrl']?.toString() ?? map['assetPath']?.toString() ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      active: map['active'] as bool? ?? true,
    );
  }
}
