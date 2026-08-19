import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:uuid/uuid.dart';

class ArticlesController extends GetxController {
  final ArticleRepository repo = Get.find();

  final loading = true.obs;
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
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    final cats = await repo.seedCategories();
    categories.assignAll(cats);
    articles.assignAll(await repo.seedArticles());
    tags.assignAll(await repo.seedTags());
    if (categories.isNotEmpty) {
      selectedCategoryId.value = categories.first.id;
      _selectFirstArticle();
    }
    loading.value = false;
  }

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

  // ---- editor ----
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

  void saveArticle(Article a) {
    final bumped = a.copyWith(
      version: a.version + (editingIsNew.value ? 0 : 1),
      updatedAt: DateTime.now(),
    );
    if (editingIsNew.value) {
      articles.add(bumped);
    } else {
      final i = articles.indexWhere((e) => e.id == a.id);
      if (i >= 0) articles[i] = bumped;
    }
    selectedArticleId.value = bumped.id;
    editing.value = null;
    AppToast.success(
      'Article saved',
      editingIsNew.value
          ? 'Article created (mock).'
          : 'Version ${bumped.version} saved (mock).',
    );
  }

  Future<void> deleteArticle(String id) async {
    articles.removeWhere((a) => a.id == id);
    if (selectedArticleId.value == id) _selectFirstArticle();
  }

  void reorderArticles(int from, int to) {
    final list = filteredArticles;
    if (from >= list.length) return;
    final item = list.removeAt(from);
    list.insert(to > from ? to - 1 : to, item);
    for (var i = 0; i < list.length; i++) {
      final idx = articles.indexWhere((a) => a.id == list[i].id);
      if (idx >= 0) {
        articles[idx] = articles[idx].copyWith(displayOrder: i);
      }
    }
  }

  // ---- categories & tags ----
  void addCategory({
    required String nameBn,
    required String nameEn,
    String subtitleBn = '',
    String subtitleEn = '',
    String imagePath = '',
    bool isFullWidth = false,
  }) {
    final id = nameEn.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    categories.add(
      ArticleCategory(
        id: id,
        nameBn: nameBn,
        nameEn: nameEn,
        subtitleBn: subtitleBn,
        subtitleEn: subtitleEn,
        imagePath: imagePath.isEmpty ? 'assets/images/articles/article_care.jpg' : imagePath,
        isFullWidth: isFullWidth,
        order: categories.length,
      ),
    );
  }

  void updateCategory(ArticleCategory cat) {
    final i = categories.indexWhere((c) => c.id == cat.id);
    if (i >= 0) {
      categories[i] = cat;
    }
  }

  void toggleCategory(String id) {
    final i = categories.indexWhere((c) => c.id == id);
    if (i >= 0) {
      categories[i] = categories[i].copyWith(active: !categories[i].active);
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    if (selectedCategoryId.value == id && categories.isNotEmpty) {
      selectedCategoryId.value = categories.first.id;
      _selectFirstArticle();
    }
  }

  void addTag(String t) {
    final v = t.trim().toLowerCase();
    if (v.isNotEmpty && !tags.contains(v)) tags.add(v);
  }

  void removeTag(String t) => tags.remove(t);
}
