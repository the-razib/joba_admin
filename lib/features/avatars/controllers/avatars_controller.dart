import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
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
      final cats = await repo.getCategories();
      categories.assignAll(cats);

      if (categories.isNotEmpty &&
          !categories.any((c) => c.id == selectedCategoryId.value)) {
        selectedCategoryId.value = categories.first.id;
      }

      final items = await repo.getAvatars();
      avatars.assignAll(items);
    } catch (e) {
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
      try {
        await repo.toggleAvatar(id);
      } catch (e) {
        avatars[i] = old; // Revert on failure
        AppToast.error('Update Failed', 'Could not update avatar visibility: $e');
      }
    }
  }

  Future<void> remove(String id) async {
    final i = avatars.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final old = avatars[i];
    avatars.removeAt(i);

    try {
      await repo.deleteAvatar(id);
      AppToast.success('Avatar Deleted', 'Avatar was successfully removed.');
    } catch (e) {
      avatars.insert(i, old); // Revert on failure
      AppToast.error('Delete Failed', 'Could not delete avatar: $e');
    }
  }

  Future<void> addCategory(String name) async {
    final cleanName = name.trim();
    final id = cleanName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    if (id.isEmpty || categories.any((c) => c.id == id)) return;

    try {
      await repo.addCategory(cleanName);
      final freshCats = await repo.getCategories();
      categories.assignAll(freshCats);
      selectedCategoryId.value = id;
      AppToast.success('Category Created', 'Category "$cleanName" was added.');
    } catch (e) {
      AppToast.error('Create Failed', 'Could not add category: $e');
    }
  }

  Future<void> toggleCategory(String id) async {
    final i = categories.indexWhere((c) => c.id == id);
    if (i >= 0) {
      final old = categories[i];
      categories[i] = old.copyWith(active: !old.active);
      try {
        await repo.toggleCategory(id);
      } catch (e) {
        categories[i] = old;
        AppToast.error('Update Failed', 'Could not toggle category: $e');
      }
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await repo.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      avatars.removeWhere((a) => a.categoryId == id);
      if (selectedCategoryId.value == id && categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
      AppToast.success('Category Deleted', 'Category and its avatars were removed.');
    } catch (e) {
      AppToast.error('Delete Failed', 'Could not delete category: $e');
    }
  }

  Future<void> uploadBatch(
    String categoryId,
    List<AvatarUploadItem> items,
  ) async {
    if (items.isEmpty) return;
    try {
      uploading.value = true;
      await repo.uploadAvatars(categoryId, items);
      final freshAvatars = await repo.getAvatars();
      avatars.assignAll(freshAvatars);
      AppToast.success(
        'Upload Complete',
        'Successfully published ${items.length} avatar(s).',
      );
    } catch (e) {
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
