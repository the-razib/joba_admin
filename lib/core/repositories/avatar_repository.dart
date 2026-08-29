import 'package:joba_admin/features/avatars/models/avatar_item.dart';

class AvatarUploadItem {
  final String id;
  final String filename;
  final List<int> bytes;

  const AvatarUploadItem({
    required this.id,
    required this.filename,
    required this.bytes,
  });
}

/// AvatarRepository contract used by AvatarsController and mocked in tests.
abstract class AvatarRepository {
  Future<List<AvatarCategory>> seedCategories();
  Future<List<AvatarCategory>> getCategories();
  Future<void> addCategory(String name);
  Future<void> toggleCategory(String id);
  Future<void> deleteCategory(String id);

  Future<List<AvatarItem>> getAvatars({String? categoryId, bool activeOnly = false});
  Future<void> uploadAvatars(String categoryId, List<AvatarUploadItem> items);
  Future<void> toggleAvatar(String id);
  Future<void> deleteAvatar(String id);

  // Legacy signatures preserved for backwards compatibility
  Future<List<AvatarItem>> fetchAvatars(String categoryId);
  Future<void> createCategory(AvatarCategory category);
  Future<void> updateCategory(AvatarCategory category);
  Future<void> saveAvatar(AvatarItem avatar);
}

class MockAvatarRepository implements AvatarRepository {
  final List<AvatarCategory> _categories = [
    const AvatarCategory(id: 'modern', name: 'Modern', order: 0, active: true),
    const AvatarCategory(id: 'simple', name: 'Simple', order: 1, active: true),
    const AvatarCategory(id: 'animal', name: 'Animal', order: 2, active: true),
    const AvatarCategory(id: 'hijab', name: 'Hijab', order: 3, active: true),
  ];

  final List<AvatarItem> _avatars = [];

  @override
  Future<List<AvatarCategory>> seedCategories() async => _categories;

  @override
  Future<List<AvatarCategory>> getCategories() async => List.unmodifiable(_categories);

  @override
  Future<void> addCategory(String name) async {
    final id = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    if (id.isEmpty || _categories.any((c) => c.id == id)) return;
    _categories.add(AvatarCategory(
      id: id,
      name: name.trim(),
      order: _categories.length,
      active: true,
    ));
  }

  @override
  Future<void> toggleCategory(String id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i != -1) {
      _categories[i] = _categories[i].copyWith(active: !_categories[i].active);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    _avatars.removeWhere((a) => a.categoryId == id);
  }

  @override
  Future<List<AvatarItem>> getAvatars({String? categoryId, bool activeOnly = false}) async {
    var list = _avatars;
    if (categoryId != null) {
      list = list.where((a) => a.categoryId == categoryId).toList();
    }
    if (activeOnly) {
      list = list.where((a) => a.active).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  Future<void> uploadAvatars(String categoryId, List<AvatarUploadItem> items) async {
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      _avatars.add(AvatarItem(
        id: item.id,
        categoryId: categoryId,
        assetPath: 'assets/images/profile_avatars/$categoryId/${item.filename}',
        order: _avatars.where((a) => a.categoryId == categoryId).length,
        active: true,
      ));
    }
  }

  @override
  Future<void> toggleAvatar(String id) async {
    final i = _avatars.indexWhere((a) => a.id == id);
    if (i != -1) {
      _avatars[i] = _avatars[i].copyWith(active: !_avatars[i].active);
    }
  }

  @override
  Future<void> deleteAvatar(String id) async {
    _avatars.removeWhere((a) => a.id == id);
  }

  // Legacy implementations
  @override
  Future<List<AvatarItem>> fetchAvatars(String categoryId) => getAvatars(categoryId: categoryId);

  @override
  Future<void> createCategory(AvatarCategory category) async => _categories.add(category);

  @override
  Future<void> updateCategory(AvatarCategory category) async {
    final i = _categories.indexWhere((c) => c.id == category.id);
    if (i != -1) _categories[i] = category;
  }

  @override
  Future<void> saveAvatar(AvatarItem avatar) async {
    final i = _avatars.indexWhere((a) => a.id == avatar.id);
    if (i != -1) {
      _avatars[i] = avatar;
    } else {
      _avatars.add(avatar);
    }
  }
}
