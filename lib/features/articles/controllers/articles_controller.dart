import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/repositories/firebase_article_repository.dart';
import 'package:joba_admin/core/services/storage_service.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';
import 'package:uuid/uuid.dart';

class ArticlesController extends GetxController {
  final ArticleRepository repo = Get.find<ArticleRepository>();
  final StorageService storageService = StorageService();

  final loading = true.obs;
  final isSaving = false.obs;
  final savingStatus = ''.obs;
  final categories = <ArticleCategory>[].obs;
  final articles = <Article>[].obs;
  final tags = <String>[].obs;

  final selectedCategoryId = Rx<String?>(null);
  final selectedArticleId = Rx<String?>(null);
  final searchController = TextEditingController();
  final searchTick = 0.obs;
  final statusFilter = 'All Status'.obs;
  final tab = 0.obs; // 0 = articles workspace, 1 = categories & tags
  final editing = Rx<Article?>(null);
  final editingIsNew = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => searchTick.value++);
    loadData();
  }

  Future<void> loadData() async {
    loading.value = true;
    try {
      final results = await Future.wait([
        repo.fetchCategories(),
        repo.fetchArticles(),
        repo.fetchTags(),
      ]);

      categories.assignAll(results[0] as List<ArticleCategory>);
      articles.assignAll(results[1] as List<Article>);
      tags.assignAll(results[2] as List<String>);

      if (categories.isNotEmpty) {
        if (selectedCategoryId.value == null ||
            !categories.any((c) => c.id == selectedCategoryId.value)) {
          selectedCategoryId.value = categories.first.id;
        }
        _selectFirstArticle();
      }
    } catch (e) {
      debugPrint('Error loading articles: $e');
      AppToast.error('Failed to load articles', e.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshData() => loadData();

  void _selectFirstArticle() {
    final list = filteredArticles;
    selectedArticleId.value = list.isNotEmpty ? list.first.id : null;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  ArticleCategory? get selectedCategory =>
      categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);

  Article? get selectedArticle =>
      articles.firstWhereOrNull((a) => a.id == selectedArticleId.value);

  List<Article> get filteredArticles {
    var list = articles
        .where((a) => a.categoryId == selectedCategoryId.value)
        .toList();
    final q = searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (a) => a.titleBn.contains(q) || a.titleEn.toLowerCase().contains(q),
          )
          .toList();
    }
    if (statusFilter.value != 'All Status') {
      list = list.where((a) {
        final s = a.status.name;
        final f = statusFilter.value.toLowerCase();
        return s == f || (f == 'in review' && s == 'review');
      }).toList();
    }
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  int countFor(String categoryId) =>
      articles.where((a) => a.categoryId == categoryId).length;

  void selectCategory(String id) {
    selectedCategoryId.value = id;
    searchController.clear();
    _selectFirstArticle();
  }

  void selectArticle(String id) => selectedArticleId.value = id;

  // ---- Editor Methods ----

  void startEdit(Article a) {
    editing.value = a;
    editingIsNew.value = false;
  }

  void startAdd() {
    editing.value = Article(
      id: const Uuid().v4(),
      categoryId: selectedCategoryId.value ?? 'care',
      titleBn: '',
      titleEn: '',
      medicalReviewerBn: 'ডাঃ সাবরিনা সুলতানা',
      medicalReviewerEn: 'Dr. Sabrina Sultana',
      isMedicallyReviewed: true,
      readingTimeMin: 3,
      status: ArticleStatus.draft,
      displayOrder: filteredArticles.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    editingIsNew.value = true;
  }

  void closeEditor() => editing.value = null;

  Future<bool> saveArticleWithMedia(
    Article a, {
    Article? previous,
    Uint8List? imageBytes,
    String? imageName,
    Uint8List? audioBnBytes,
    String? audioBnName,
    Uint8List? audioEnBytes,
    String? audioEnName,
  }) async {
    isSaving.value = true;
    savingStatus.value = 'Preparing article...';
    try {
      var updated = a;

      // Upload Cover Image if freshly picked
      if (imageBytes != null && imageBytes.isNotEmpty) {
        savingStatus.value = 'Uploading cover image to Firebase Storage...';
        final url = await storageService.uploadBytes(
          folder: 'articles/${a.id}',
          name: imageName ?? 'cover.jpg',
          bytes: imageBytes,
        );
        updated = updated.copyWith(imagePath: url);
      }

      // Upload Bengali Audio if freshly picked
      if (audioBnBytes != null && audioBnBytes.isNotEmpty) {
        savingStatus.value = 'Uploading Bengali audio narration to Storage...';
        final url = await storageService.uploadBytes(
          folder: 'articles/${a.id}',
          name: audioBnName ?? 'audio_bn.mp3',
          bytes: audioBnBytes,
        );
        updated = updated.copyWith(audioBnPath: url);
      }

      // Upload English Audio if freshly picked
      if (audioEnBytes != null && audioEnBytes.isNotEmpty) {
        savingStatus.value = 'Uploading English audio narration to Storage...';
        final url = await storageService.uploadBytes(
          folder: 'articles/${a.id}',
          name: audioEnName ?? 'audio_en.mp3',
          bytes: audioEnBytes,
        );
        updated = updated.copyWith(audioEnPath: url);
      }

      savingStatus.value = 'Saving article content to Firestore...';
      final bumped = updated.copyWith(
        version: updated.version + (editingIsNew.value ? 0 : 1),
        updatedAt: DateTime.now(),
      );

      await repo.saveArticle(bumped);
      savingStatus.value = 'Finalizing...';

      // Best-effort cleanup: delete replaced or removed media files from
      // Storage so old uploads don't orphan and accumulate cost.
      if (previous != null) {
        _deleteStaleStorageFile(previous.imagePath, bumped.imagePath);
        _deleteStaleStorageFile(previous.audioBnPath, bumped.audioBnPath);
        _deleteStaleStorageFile(previous.audioEnPath, bumped.audioEnPath);
      }

      final i = articles.indexWhere((e) => e.id == a.id);
      if (i >= 0) {
        articles[i] = bumped;
      } else {
        articles.add(bumped);
      }

      selectedArticleId.value = bumped.id;
      editing.value = null;
      AppToast.success(
        'Article Saved',
        editingIsNew.value
            ? 'Article "${bumped.titleEn}" created successfully.'
            : 'Article "${bumped.titleEn}" updated.',
      );
      return true;
    } catch (e) {
      debugPrint('Error saving article: $e');
      AppToast.error('Save Failed', e.toString());
      return false;
    } finally {
      isSaving.value = false;
      savingStatus.value = '';
    }
  }

  void saveArticle(Article a) {
    saveArticleWithMedia(a);
  }

  /// Deletes a previous Storage file when it was replaced or removed.
  /// Errors are swallowed by StorageService.deleteFile (best-effort).
  void _deleteStaleStorageFile(String? previousUrl, String? currentUrl) {
    if (previousUrl == null || !previousUrl.startsWith('http')) return;
    if (previousUrl == currentUrl) return;
    storageService.deleteFile(previousUrl);
  }

  Future<void> deleteArticle(String id) async {
    try {
      final target = articles.firstWhereOrNull((a) => a.id == id);

      // Permanently delete Firestore document & Storage files
      await repo.deleteArticle(id);

      // Additional direct storage cleanup to ensure no orphaned files remain
      await storageService.deleteFolder('articles/$id');
      if (target != null) {
        if (target.imagePath.startsWith('http')) {
          await storageService.deleteFile(target.imagePath);
        }
        if (target.audioBnPath != null && target.audioBnPath!.startsWith('http')) {
          await storageService.deleteFile(target.audioBnPath!);
        }
        if (target.audioEnPath != null && target.audioEnPath!.startsWith('http')) {
          await storageService.deleteFile(target.audioEnPath!);
        }
      }

      articles.removeWhere((a) => a.id == id);
      if (selectedArticleId.value == id) _selectFirstArticle();
      AppToast.success(
        'Article Deleted',
        'Article and all associated media files permanently removed.',
      );
    } catch (e) {
      debugPrint('Error deleting article: $e');
      AppToast.error('Delete Failed', e.toString());
      await loadData();
    }
  }

  Future<void> reorderArticles(int from, int to) async {
    final list = List<Article>.from(filteredArticles);
    if (list.length <= 1) return;
    if (from < 0 || from >= list.length) return;
    var target = to;
    if (target > from) target -= 1;
    if (target < 0) target = 0;
    if (target >= list.length) target = list.length - 1;
    if (from == target) return;

    final item = list.removeAt(from);
    list.insert(target, item);

    for (var i = 0; i < list.length; i++) {
      final idx = articles.indexWhere((a) => a.id == list[i].id);
      if (idx >= 0) {
        articles[idx] = articles[idx].copyWith(displayOrder: i);
      }
    }

    try {
      final orderedIds = list.map((a) => a.id).toList();
      await repo.reorderArticles(orderedIds);
    } catch (e) {
      debugPrint('Error reordering articles: $e');
      AppToast.error('Reorder Failed', e.toString());
      await loadData();
    }
  }

  // ---- Categories & Tags Management ----

  Future<void> addCategory({
    required String nameBn,
    required String nameEn,
    String subtitleBn = '',
    String subtitleEn = '',
    String imagePath = '',
    Uint8List? imageBytes,
    String? imageName,
    bool isFullWidth = false,
  }) async {
    final id = nameEn.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );

    var finalImagePath = imagePath;

    if (imageBytes != null && imageBytes.isNotEmpty) {
      try {
        finalImagePath = await storageService.uploadBytes(
          folder: 'article_categories/$id',
          name: imageName ?? 'banner.jpg',
          bytes: imageBytes,
        );
      } catch (e) {
        debugPrint('Error uploading category banner: $e');
        AppToast.error(
          'Image Upload Failed',
          'Failed to upload category cover: $e',
        );
        return;
      }
    }

    final cat = ArticleCategory(
      id: id,
      nameBn: nameBn,
      nameEn: nameEn,
      subtitleBn: subtitleBn,
      subtitleEn: subtitleEn,
      imagePath: finalImagePath,
      isFullWidth: isFullWidth,
      order: categories.length,
      active: true,
    );

    try {
      await repo.saveCategory(cat);
      categories.add(cat);
      AppToast.success('Category Created', 'Category "${cat.nameEn}" added.');
    } catch (e) {
      debugPrint('Error adding category: $e');
      AppToast.error('Create Category Failed', e.toString());
    }
  }

  Future<void> updateCategory(
    ArticleCategory cat, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    var updated = cat;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      try {
        final url = await storageService.uploadBytes(
          folder: 'article_categories/${cat.id}',
          name: imageName ?? 'banner.jpg',
          bytes: imageBytes,
        );
        updated = updated.copyWith(imagePath: url);
      } catch (e) {
        debugPrint('Error uploading category banner: $e');
        AppToast.error(
          'Image Upload Failed',
          'Failed to upload category cover: $e',
        );
        return;
      }
    }

    try {
      await repo.saveCategory(updated);
      final i = categories.indexWhere((c) => c.id == updated.id);
      if (i >= 0) categories[i] = updated;
      AppToast.success(
        'Category Updated',
        'Category "${updated.nameEn}" updated.',
      );
    } catch (e) {
      debugPrint('Error updating category: $e');
      AppToast.error('Update Category Failed', e.toString());
    }
  }

  Future<void> toggleCategory(String id) async {
    final i = categories.indexWhere((c) => c.id == id);
    if (i >= 0) {
      final newActive = !categories[i].active;
      categories[i] = categories[i].copyWith(active: newActive);
      try {
        await repo.toggleCategory(id, newActive);
        AppToast.success(
          newActive ? 'Category Activated' : 'Category Deactivated',
          'Category "${categories[i].nameEn}" is now ${newActive ? 'active' : 'inactive'}.',
        );
      } catch (e) {
        categories[i] = categories[i].copyWith(active: !newActive);
        AppToast.error('Failed to toggle category', e.toString());
      }
    }
  }

  Future<void> deleteCategory(String id) async {
    final count = countFor(id);
    if (count > 0) {
      AppToast.warning(
        'Cannot Delete Category',
        'This category contains $count article${count == 1 ? '' : 's'}. Move or delete those articles first, or toggle it to inactive.',
      );
      return;
    }

    try {
      await repo.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      if (selectedCategoryId.value == id && categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
        _selectFirstArticle();
      }
      AppToast.success('Category Deleted', 'Category has been removed.');
    } catch (e) {
      debugPrint('Error deleting category: $e');
      AppToast.error('Delete Category Failed', e.toString());
      await loadData();
    }
  }

  Future<void> addTag(String t) async {
    final v = t.trim().toLowerCase();
    if (v.isEmpty || tags.contains(v)) return;
    try {
      await repo.addTag(v);
      tags.add(v);
      AppToast.success('Tag Added', '#$v added.');
    } catch (e) {
      debugPrint('Error adding tag: $e');
      AppToast.error('Add Tag Failed', e.toString());
    }
  }

  Future<void> removeTag(String t) async {
    final v = t.trim().toLowerCase();
    try {
      await repo.deleteTag(v);
      tags.remove(v);
      AppToast.success('Tag Removed', '#$v removed.');
    } catch (e) {
      debugPrint('Error removing tag: $e');
      AppToast.error('Remove Tag Failed', e.toString());
    }
  }

  /// Trigger one-time migration to seed default verified content to Firestore
  Future<void> seedDefaultContent() async {
    try {
      loading.value = true;
      if (repo is FirebaseArticleRepository) {
        await (repo as FirebaseArticleRepository).migrateInitialSeedData();
      }
      await loadData();
      AppToast.success(
        'Initial Content Seeded',
        'Successfully populated Firestore with default articles, categories, and tags.',
      );
    } catch (e) {
      debugPrint('Error seeding default content: $e');
      AppToast.error('Seeding Failed', e.toString());
    } finally {
      loading.value = false;
    }
  }
}
