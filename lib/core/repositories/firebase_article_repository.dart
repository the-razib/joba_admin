import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/core/services/storage_service.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';

/// Production Firebase repository for Articles, Categories, and Tags CMS.
/// Pure CRUD & Read operations without runtime auto-seeding.
class FirebaseArticleRepository implements ArticleRepository {
  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  FirebaseArticleRepository({
    FirebaseFirestore? firestore,
    StorageService? storageService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService ?? StorageService();

  static const String _categoriesCol = 'article_categories';
  static const String _articlesCol = 'articles';
  static const String _tagsCol = 'article_tags';

  @override
  Future<List<ArticleCategory>> fetchCategories() async {
    try {
      final snap = await _firestore
          .collection(_categoriesCol)
          .orderBy('order')
          .get();

      return snap.docs
          .map((doc) => ArticleCategory.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching article categories: $e');
      try {
        final fallback = await _firestore.collection(_categoriesCol).get();
        return fallback.docs
            .map((doc) => ArticleCategory.fromMap(doc.data(), docId: doc.id))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<List<Article>> fetchArticles() async {
    try {
      final snap = await _firestore
          .collection(_articlesCol)
          .orderBy('displayOrder')
          .get();

      return snap.docs
          .map((doc) => Article.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      try {
        final fallback = await _firestore.collection(_articlesCol).get();
        return fallback.docs
            .map((doc) => Article.fromMap(doc.data(), docId: doc.id))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<List<String>> fetchTags() async {
    try {
      final snap = await _firestore.collection(_tagsCol).get();
      return snap.docs.map((d) => d.id).toList();
    } catch (e) {
      debugPrint('Error fetching article tags: $e');
      return [];
    }
  }

  @override
  Future<Article?> fetchArticleById(String id) async {
    try {
      final doc = await _firestore.collection(_articlesCol).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return Article.fromMap(doc.data()!, docId: doc.id);
    } catch (e) {
      debugPrint('Error fetching article $id: $e');
      return null;
    }
  }

  @override
  Future<void> saveArticle(Article article) async {
    final docRef = _firestore.collection(_articlesCol).doc(article.id);
    final existing = await docRef.get();
    final isNew = !existing.exists;

    final data = article.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (isNew) {
      data['createdAt'] = FieldValue.serverTimestamp();
    } else {
      // Preserve live mobile analytics counters by not clobbering them with stale admin session values
      data.remove('views');
      data.remove('bookmarks');
      data.remove('likes');
      data.remove('commentsCount');
      data.remove('shares');
    }

    await docRef.set(data, SetOptions(merge: true));

    await AuditService.log(
      module: 'Articles CMS',
      action: isNew ? AuditAction.created : AuditAction.updated,
      details: '${isNew ? 'Created' : 'Updated'} article "${article.titleEn}" (${article.id}) [${article.status.label}]',
    );
  }

  @override
  Future<void> deleteArticle(String id) async {
    final docRef = _firestore.collection(_articlesCol).doc(id);
    final existing = await docRef.get();
    final data = existing.data();
    final title = data?['titleEn'] ?? data?['title_en'] ?? id;

    // Delete Firestore document
    await docRef.delete();

    // Permanently delete article folder from Firebase Storage (removes all files & subfolders)
    await _storageService.deleteFolder('articles/$id');

    // Also delete individual media files if stored outside the default folder
    final imgUrl = data?['imageUrl'] ?? data?['imagePath'];
    if (imgUrl != null && imgUrl.toString().startsWith('http')) {
      await _storageService.deleteFile(imgUrl.toString());
    }
    final audioBn = data?['audioBnPath'] ?? data?['audioUrl']?['bn'];
    if (audioBn != null && audioBn.toString().startsWith('http')) {
      await _storageService.deleteFile(audioBn.toString());
    }
    final audioEn = data?['audioEnPath'] ?? data?['audioUrl']?['en'];
    if (audioEn != null && audioEn.toString().startsWith('http')) {
      await _storageService.deleteFile(audioEn.toString());
    }

    await AuditService.log(
      module: 'Articles CMS',
      action: AuditAction.deleted,
      details: 'Deleted article "$title" ($id)',
    );
  }

  @override
  Future<void> saveCategory(ArticleCategory category) async {
    final docRef = _firestore.collection(_categoriesCol).doc(category.id);
    final existing = await docRef.get();
    final isNew = !existing.exists;

    final data = category.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (isNew) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(data, SetOptions(merge: true));

    await AuditService.log(
      module: 'Articles CMS',
      action: isNew ? AuditAction.created : AuditAction.updated,
      details: '${isNew ? 'Created' : 'Updated'} category "${category.nameEn}" (${category.id})',
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final docRef = _firestore.collection(_categoriesCol).doc(id);
    final doc = await docRef.get();
    final data = doc.data();
    final imgUrl = data?['imagePath'] ?? data?['imageUrl'];
    if (imgUrl != null && imgUrl.toString().startsWith('http')) {
      _storageService.deleteFile(imgUrl.toString());
    }

    await docRef.delete();

    await AuditService.log(
      module: 'Articles CMS',
      action: AuditAction.deleted,
      details: 'Deleted category $id',
    );
  }

  @override
  Future<void> toggleCategory(String id, bool active) async {
    await _firestore.collection(_categoriesCol).doc(id).update({
      'active': active,
      'isActive': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await AuditService.log(
      module: 'Articles CMS',
      action: AuditAction.updated,
      details: '${active ? 'Activated' : 'Deactivated'} category $id',
    );
  }

  @override
  Future<void> reorderArticles(List<String> orderedIds) async {
    final batch = _firestore.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      final docRef = _firestore.collection(_articlesCol).doc(orderedIds[i]);
      batch.update(docRef, {
        'displayOrder': i,
        'order': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    await AuditService.log(
      module: 'Articles CMS',
      action: AuditAction.updated,
      details: 'Reordered ${orderedIds.length} articles',
    );
  }

  @override
  Future<void> addTag(String tag) async {
    final clean = tag.trim().toLowerCase();
    if (clean.isEmpty) return;
    await _firestore.collection(_tagsCol).doc(clean).set({
      'tag': clean,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await AuditService.log(
      module: 'Articles CMS',
      action: AuditAction.created,
      details: 'Added tag #$clean',
    );
  }

  @override
  Future<void> deleteTag(String tag) async {
    final clean = tag.trim().toLowerCase();
    await _firestore.collection(_tagsCol).doc(clean).delete();

    await AuditService.log(
      module: 'Articles CMS',
      action: AuditAction.deleted,
      details: 'Removed tag #$clean',
    );
  }

  /// Explicit one-time migration to seed initial verified content to Firestore.
  Future<void> migrateInitialSeedData() async {
    final mock = MockArticleRepository();
    final batch = _firestore.batch();

    // Seed categories
    final cats = await mock.seedCategories();
    for (final cat in cats) {
      final docRef = _firestore.collection(_categoriesCol).doc(cat.id);
      final data = cat.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      batch.set(docRef, data, SetOptions(merge: true));
    }

    // Seed articles
    final arts = await mock.seedArticles();
    for (final art in arts) {
      final docRef = _firestore.collection(_articlesCol).doc(art.id);
      final data = art.toMap()
        ..remove('views')
        ..remove('bookmarks')
        ..remove('likes')
        ..remove('commentsCount')
        ..remove('shares');
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      batch.set(docRef, data, SetOptions(merge: true));
    }

    // Seed tags
    final tags = await mock.seedTags();
    for (final tag in tags) {
      final docRef = _firestore.collection(_tagsCol).doc(tag);
      batch.set(docRef, {
        'tag': tag,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();

    await AuditService.log(
      module: 'Articles CMS',
      action: AuditAction.created,
      details: 'Executed one-time initial article & category migration to Firestore',
    );
  }

  @override
  Future<List<ArticleCategory>> seedCategories() => fetchCategories();

  @override
  Future<List<Article>> seedArticles() => fetchArticles();

  @override
  Future<List<String>> seedTags() => fetchTags();

  @override
  Future<void> createArticle(Article article) => saveArticle(article);

  @override
  Future<void> updateArticle(Article article) => saveArticle(article);

  @override
  Future<void> createCategory(ArticleCategory category) => saveCategory(category);

  @override
  Future<void> updateCategory(ArticleCategory category) => saveCategory(category);
}
