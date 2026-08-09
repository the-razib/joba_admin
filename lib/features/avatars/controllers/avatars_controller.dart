import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/avatar_item.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:uuid/uuid.dart';

/// Manages the preset avatar library. Phase 1 reads the same bundled
/// assets the app ships; Phase 3 swaps to Firestore + Storage.
class AvatarsController extends GetxController {
  final AvatarRepository repo = Get.find();

  final loading = true.obs;
  final categories = <AvatarCategory>[].obs;
  final avatars = <AvatarItem>[].obs;
  final selectedCategoryId = 'modern'.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    categories.assignAll(await repo.seedCategories());

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final items = <AvatarItem>[];
    for (final cat in categories) {
      final prefix = 'assets/images/profile_avatars/${cat.id}/';
      final paths = manifest
          .listAssets()
          .where((k) => k.startsWith(prefix))
          .toList()
        ..sort();
      for (var i = 0; i < paths.length; i++) {
        items.add(AvatarItem(
          id: paths[i].split('/').last,
          categoryId: cat.id,
          assetPath: paths[i],
          order: i,
        ));
      }
    }
    avatars.assignAll(items);
    loading.value = false;
  }

  List<AvatarItem> avatarsFor(String categoryId) => avatars
      .where((a) => a.categoryId == categoryId)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  int countFor(String categoryId) =>
      avatars.where((a) => a.categoryId == categoryId).length;

  void selectCategory(String id) => selectedCategoryId.value = id;

  void toggleActive(String id) {
    final i = avatars.indexWhere((a) => a.id == id);
    if (i >= 0) avatars[i] = avatars[i].copyWith(active: !avatars[i].active);
  }

  void remove(String id) => avatars.removeWhere((a) => a.id == id);

  void addPicked(List<AvatarItem> picked) {
    avatars.addAll(picked);
  }

  void addCategory(String name) {
    final id = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    if (id.isEmpty || categories.any((c) => c.id == id)) return;
    categories.add(AvatarCategory(id: id, name: name.trim(), order: categories.length));
  }

  AvatarItem newItem({required String categoryId, required List<int> bytes}) {
    final base = avatarsFor(categoryId).length;
    return AvatarItem(
      id: const Uuid().v4(),
      categoryId: categoryId,
      assetPath: '',
      order: base,
      pendingBytes: bytes,
    );
  }
}
