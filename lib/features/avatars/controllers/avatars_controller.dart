import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/avatars/models/avatar_item.dart';
import 'package:uuid/uuid.dart';

/// Manages the preset avatar library connected to Firestore and Storage.
class AvatarsController extends GetxController {
  final AvatarRepository repo = Get.find();

  final loading = true.obs;
  final uploading = false.obs;
  final categories = <AvatarCategory>[].obs;
  final avatars = <AvatarItem>[].obs;
  final selectedCategoryId = 'modern'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      loading.value = true;
      AppLoggerHelper.info('[AvatarsController] 🎨 Loading avatar library and categories...');
      final cats = await repo.getCategories();
      categories.assignAll(cats);

      if (categories.isNotEmpty &&
          !categories.any((c) => c.id == selectedCategoryId.value)) {
        selectedCategoryId.value = categories.first.id;
      }

      final items = await repo.getAvatars();
      avatars.assignAll(items);
      AppLoggerHelper.success('AvatarsController', 'Loaded ${categories.length} categories, ${avatars.length} avatars');
    } catch (e, st) {
      AppLoggerHelper.failure('AvatarsController', 'Could not load avatars: $e', error: e, stackTrace: st);
      AppToast.error('Load Failed', 'Could not load avatars: $e');
    } finally {
      loading.value = false;
    }
  }

  List<AvatarItem> avatarsFor(String categoryId) => avatars
      .where((a) => a.categoryId == categoryId)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  int countFor(String categoryId) =>
      avatars.where((a) => a.categoryId == categoryId).length;

  void selectCategory(String id) => selectedCategoryId.value = id;

  Future<void> toggleActive(String id) async {
    final i = avatars.indexWhere((a) => a.id == id);
    if (i >= 0) {
      final old = avatars[i];
      avatars[i] = old.copyWith(active: !old.active);
      AppLoggerHelper.info('[AvatarsController] 🔄 Toggling avatar $id to active: ${avatars[i].active}');
      try {
        await repo.toggleAvatar(id);
        AppLoggerHelper.success('AvatarsController', 'Avatar $id active: ${avatars[i].active}');
      } catch (e, st) {
        avatars[i] = old; // Revert on failure
        AppLoggerHelper.failure('AvatarsController', 'Could not update avatar visibility: $e', error: e, stackTrace: st);
        AppToast.error('Update Failed', 'Could not update avatar visibility: $e');
      }
    }
  }

  Future<void> remove(String id) async {
    final i = avatars.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final old = avatars[i];
    avatars.removeAt(i);
    AppLoggerHelper.info('[AvatarsController] 🗑️ Deleting avatar $id...');

    try {
      await repo.deleteAvatar(id);
      AppLoggerHelper.success('AvatarsController', 'Deleted avatar $id');
      AppToast.success('Avatar Deleted', 'Avatar was successfully removed.');
    } catch (e, st) {
      avatars.insert(i, old); // Revert on failure
      AppLoggerHelper.failure('AvatarsController', 'Could not delete avatar: $e', error: e, stackTrace: st);
      AppToast.error('Delete Failed', 'Could not delete avatar: $e');
    }
  }

  Future<void> addCategory(String name) async {
    final cleanName = name.trim();
    final id = cleanName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    if (id.isEmpty || categories.any((c) => c.id == id)) return;

    AppLoggerHelper.info('[AvatarsController] ➕ Adding avatar category: "$cleanName"');
    try {
      await repo.addCategory(cleanName);
      final freshCats = await repo.getCategories();
      categories.assignAll(freshCats);
      selectedCategoryId.value = id;
      AppLoggerHelper.success('AvatarsController', 'Created avatar category: "$cleanName"');
      AppToast.success('Category Created', 'Category "$cleanName" was added.');
    } catch (e, st) {
      AppLoggerHelper.failure('AvatarsController', 'Could not add category: $e', error: e, stackTrace: st);
      AppToast.error('Create Failed', 'Could not add category: $e');
    }
  }

  Future<void> toggleCategory(String id) async {
    final i = categories.indexWhere((c) => c.id == id);
    if (i >= 0) {
      final old = categories[i];
      categories[i] = old.copyWith(active: !old.active);
      AppLoggerHelper.info('[AvatarsController] 🔄 Toggling avatar category $id active: ${categories[i].active}');
      try {
        await repo.toggleCategory(id);
        AppLoggerHelper.success('AvatarsController', 'Avatar category $id active: ${categories[i].active}');
      } catch (e, st) {
        categories[i] = old;
        AppLoggerHelper.failure('AvatarsController', 'Could not toggle category: $e', error: e, stackTrace: st);
        AppToast.error('Update Failed', 'Could not toggle category: $e');
      }
    }
  }

  Future<void> deleteCategory(String id) async {
    AppLoggerHelper.info('[AvatarsController] 🗑️ Deleting avatar category: $id');
    try {
      await repo.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      avatars.removeWhere((a) => a.categoryId == id);
      if (selectedCategoryId.value == id && categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
      AppLoggerHelper.success('AvatarsController', 'Deleted avatar category: $id');
      AppToast.success('Category Deleted', 'Category and its avatars were removed.');
    } catch (e, st) {
      AppLoggerHelper.failure('AvatarsController', 'Could not delete category: $e', error: e, stackTrace: st);
      AppToast.error('Delete Failed', 'Could not delete category: $e');
    }
  }

  Future<void> uploadBatch(
    String categoryId,
    List<AvatarUploadItem> items,
  ) async {
    if (items.isEmpty) return;
    AppLoggerHelper.info('[AvatarsController] 📤 Uploading batch of ${items.length} avatars for category $categoryId...');
    try {
      uploading.value = true;
      await repo.uploadAvatars(categoryId, items);
      final freshAvatars = await repo.getAvatars();
      avatars.assignAll(freshAvatars);
      AppLoggerHelper.success('AvatarsController', 'Successfully published ${items.length} avatar(s)');
      AppToast.success(
        'Upload Complete',
        'Successfully published ${items.length} avatar(s).',
      );
    } catch (e, st) {
      AppLoggerHelper.failure('AvatarsController', 'Error publishing avatars: $e', error: e, stackTrace: st);
      AppToast.error('Upload Failed', 'Error publishing avatars: $e');
    } finally {
      uploading.value = false;
    }
  }

  AvatarItem newItem({
    required String categoryId,
    required List<int> bytes,
    String? filename,
  }) {
    final base = avatarsFor(categoryId).length;
    return AvatarItem(
      id: filename ?? const Uuid().v4(),
      categoryId: categoryId,
      assetPath: '',
      order: base,
      pendingBytes: bytes,
    );
  }
}
