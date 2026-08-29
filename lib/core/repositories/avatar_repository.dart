import 'package:joba_admin/features/avatars/models/avatar_item.dart';

/// Phase 1: seeds match the app's bundled asset folders.
/// Phase 3: `FirebaseAvatarRepository` reads `avatar_categories` + `avatars`
/// and uploads to Firebase Storage.
abstract class AvatarRepository {
  Future<List<AvatarCategory>> seedCategories();
  Future<List<AvatarItem>> fetchAvatars(String categoryId);
  Future<void> createCategory(AvatarCategory category);
  Future<void> updateCategory(AvatarCategory category);
  Future<void> deleteCategory(String id);
  Future<void> saveAvatar(AvatarItem avatar);
  Future<void> deleteAvatar(String id);
}

class MockAvatarRepository implements AvatarRepository {
  @override
  Future<List<AvatarCategory>> seedCategories() async => const [
        AvatarCategory(id: 'modern', name: 'Modern', order: 0),
        AvatarCategory(id: 'simple', name: 'Simple', order: 1),
        AvatarCategory(id: 'animal', name: 'Animal', order: 2),
        AvatarCategory(id: 'hijab', name: 'Hijab', order: 3),
      ];

  @override
  Future<List<AvatarItem>> fetchAvatars(String categoryId) async => const [];

  @override
  Future<void> createCategory(AvatarCategory category) async {}

  @override
  Future<void> updateCategory(AvatarCategory category) async {}

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> saveAvatar(AvatarItem avatar) async {}

  @override
  Future<void> deleteAvatar(String id) async {}
}
