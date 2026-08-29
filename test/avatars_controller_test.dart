import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';

void main() {
  late MockAvatarRepository mockRepo;
  late AvatarsController controller;

  setUp(() async {
    Get.testMode = true;
    Get.put(ThemeService());
    mockRepo = MockAvatarRepository();
    Get.put<AvatarRepository>(mockRepo);
    controller = Get.put(AvatarsController());
    await controller.load();
  });

  tearDown(() {
    Get.reset();
  });

  test('controller loads initial categories and defaults to modern', () async {
    expect(controller.loading.value, isFalse);
    expect(controller.categories, isNotEmpty);
    expect(controller.selectedCategoryId.value, 'modern');
    expect(controller.categories.map((c) => c.id),
        containsAll(['modern', 'simple', 'animal', 'hijab']));
  });

  test('uploadBatch adds avatars to repository and updates local list', () async {
    final uploadItems = [
      const AvatarUploadItem(
        id: 'new_avatar_01',
        filename: 'new_avatar_01.png',
        bytes: [1, 2, 3, 4],
      ),
      const AvatarUploadItem(
        id: 'new_avatar_02',
        filename: 'new_avatar_02.png',
        bytes: [5, 6, 7, 8],
      ),
    ];

    await controller.uploadBatch('modern', uploadItems);

    final modernAvatars = controller.avatarsFor('modern');
    expect(modernAvatars.length, 2);
    expect(modernAvatars.map((a) => a.id),
        containsAll(['new_avatar_01', 'new_avatar_02']));
  });

  test('toggleActive toggles the active state of an avatar', () async {
    await controller.uploadBatch('modern', [
      const AvatarUploadItem(
        id: 'toggle_avatar',
        filename: 'toggle_avatar.png',
        bytes: [1, 2, 3],
      ),
    ]);

    final avatar = controller.avatarsFor('modern').firstWhere((a) => a.id == 'toggle_avatar');
    expect(avatar.active, isTrue);

    await controller.toggleActive('toggle_avatar');
    final toggled = controller.avatarsFor('modern').firstWhere((a) => a.id == 'toggle_avatar');
    expect(toggled.active, isFalse);
  });

  test('remove deletes an avatar from controller and repository', () async {
    await controller.uploadBatch('modern', [
      const AvatarUploadItem(
        id: 'delete_me',
        filename: 'delete_me.png',
        bytes: [1, 2, 3],
      ),
    ]);

    expect(controller.avatarsFor('modern').any((a) => a.id == 'delete_me'), isTrue);

    await controller.remove('delete_me');
    expect(controller.avatarsFor('modern').any((a) => a.id == 'delete_me'), isFalse);
  });

  test('addCategory creates new category and selects it', () async {
    await controller.addCategory('3D Icons');

    expect(controller.categories.any((c) => c.name == '3D Icons'), isTrue);
    expect(controller.selectedCategoryId.value, '3d_icons');
  });

  test('deleteCategory removes category and its avatars', () async {
    await controller.addCategory('Temporary');
    await controller.uploadBatch('temporary', [
      const AvatarUploadItem(
        id: 'temp_01',
        filename: 'temp_01.png',
        bytes: [1, 2],
      ),
    ]);

    expect(controller.categories.any((c) => c.id == 'temporary'), isTrue);
    expect(controller.avatarsFor('temporary'), isNotEmpty);

    await controller.deleteCategory('temporary');
    expect(controller.categories.any((c) => c.id == 'temporary'), isFalse);
    expect(controller.avatarsFor('temporary'), isEmpty);
  });
}
