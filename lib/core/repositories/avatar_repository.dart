import 'package:joba_admin/features/avatars/models/avatar_item.dart';

/// Phase 1: seeds match the app's bundled asset folders.
/// Phase 3: `FirebaseAvatarRepository` reads `avatar_categories` + `avatars`
/// and uploads to Firebase Storage.
abstract class AvatarRepository {
  Future<List<AvatarCategory>> seedCategories();
}

class MockAvatarRepository implements AvatarRepository {
  @override
  Future<List<AvatarCategory>> seedCategories() async => const [
        AvatarCategory(id: 'modern', name: 'Modern', order: 0),
        AvatarCategory(id: 'simple', name: 'Simple', order: 1),
        AvatarCategory(id: 'animal', name: 'Animal', order: 2),
        AvatarCategory(id: 'hijab', name: 'Hijab', order: 3),
      ];
}
