import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';
import 'package:joba_admin/features/articles/views/screens/articles_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<ArticleRepository>(MockArticleRepository());

    final authService = AuthService();
    authService.user.value = const AdminUser(
      uid: 'adm-001',
      name: 'Super Admin',
      email: 'admin@joba.com',
      role: AdminRole.superAdmin,
    );
    Get.put(authService);
  });

  tearDown(Get.reset);

  group('Article Models Serialization Tests', () {
    test('Article round-trip toMap and fromMap with dual mobile compatibility', () {
      final now = DateTime(2026, 9, 1);
      final article = Article(
        id: 'art-test-1',
        categoryId: 'period',
        titleBn: 'পিরিয়ড স্বাস্থ্য',
        titleEn: 'Period Health',
        subtitleBn: 'স্বাস্থ্য বিষয়ক তথ্য',
        subtitleEn: 'Health info',
        contentBn: 'বিস্তারিত কনটেন্ট বাংলা',
        contentEn: 'Detailed content English',
        imagePath: 'https://storage.googleapis.com/test.jpg',
        tags: const ['period', 'health'],
        status: ArticleStatus.published,
        featured: true,
        displayOrder: 2,
        createdAt: now,
        updatedAt: now,
      );

      final map = article.toMap();

      expect(map['category'], 'period');
      expect(map['isPublished'], isTrue);
      expect(map['title_bn'], 'পিরিয়ড স্বাস্থ্য');
      expect(map['title_en'], 'Period Health');
      expect(map['order'], 2);

      final fromMap = Article.fromMap(map, docId: 'art-test-1');
      expect(fromMap.id, 'art-test-1');
      expect(fromMap.titleBn, 'পিরিয়ড স্বাস্থ্য');
      expect(fromMap.titleEn, 'Period Health');
      expect(fromMap.status, ArticleStatus.published);
      expect(fromMap.featured, isTrue);
    });

    test('ArticleCategory round-trip toMap and fromMap', () {
      const cat = ArticleCategory(
        id: 'care',
        nameBn: 'যত্ন',
        nameEn: 'Self-Care',
        subtitleBn: 'শারীরিক যত্ন',
        subtitleEn: 'Physical Care',
        imagePath: 'assets/care.jpg',
        isFullWidth: true,
        order: 1,
        active: true,
      );

      final map = cat.toMap();
      expect(map['isActive'], isTrue);
      expect(map['name_en'], 'Self-Care');

      final fromMap = ArticleCategory.fromMap(map, docId: 'care');
      expect(fromMap.id, 'care');
      expect(fromMap.nameEn, 'Self-Care');
      expect(fromMap.isFullWidth, isTrue);
      expect(fromMap.active, isTrue);
    });
  });

  group('ArticleRepository Tests', () {
    test('MockArticleRepository handles CRUD and reordering', () async {
      final repo = MockArticleRepository();

      final cats = await repo.fetchCategories();
      expect(cats.isNotEmpty, isTrue);

      final arts = await repo.fetchArticles();
      expect(arts.length, 6);

      // Save new article
      final newArt = Article(
        id: 'art-new-1',
        categoryId: 'care',
        titleBn: 'নতুন আর্টিকেল',
        titleEn: 'New Article',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.saveArticle(newArt);

      final updatedArts = await repo.fetchArticles();
      expect(updatedArts.length, 7);

      // Reorder
      await repo.reorderArticles(['art-new-1', 'art_care_001', 'art_period_001']);
      final reordered = await repo.fetchArticles();
      expect(reordered.first.id, 'art-new-1');

      // Delete
      await repo.deleteArticle('art-new-1');
      final afterDelete = await repo.fetchArticles();
      expect(afterDelete.length, 6);
    });
  });

  group('ArticlesController Tests', () {
    setUp(() {
      Get.delete<ArticlesController>();
      Get.delete<ArticleRepository>();
      Get.put<ArticleRepository>(MockArticleRepository());
    });

    test('loads initial data and selects category', () async {
      final controller = Get.put(ArticlesController());
      await controller.loadData();

      expect(controller.categories.isNotEmpty, isTrue);
      expect(controller.articles.isNotEmpty, isTrue);
      expect(controller.selectedCategoryId.value, isNotNull);
      expect(controller.selectedArticleId.value, isNotNull);
    });

    test('filters articles by search and status', () async {
      final controller = Get.put(ArticlesController());
      await controller.loadData();

      controller.selectCategory('period');
      final initialCount = controller.filteredArticles.length;
      expect(initialCount, greaterThan(0));

      controller.searchController.text = 'ব্যথা';
      expect(controller.filteredArticles.every((a) => a.titleBn.contains('ব্যথা')), isTrue);

      controller.searchController.clear();
      controller.statusFilter.value = 'Draft';
      expect(controller.filteredArticles.isEmpty, isTrue);
    });

    test('reorders articles and persists order', () async {
      final controller = Get.put(ArticlesController());
      await controller.loadData();

      // Add a second article to 'care' to test reordering
      final secondArt = Article(
        id: 'art_care_002',
        categoryId: 'care',
        titleBn: 'দ্বিতীয় আর্টিকেল',
        titleEn: 'Second Article',
        status: ArticleStatus.published,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await controller.saveArticleWithMedia(secondArt);
      controller.statusFilter.value = 'All Status';
      controller.selectCategory('care');
      expect(controller.filteredArticles.length, 2);

      final initialFirst = controller.filteredArticles.first.id;
      await controller.reorderArticles(0, 2);
      final newFirst = controller.filteredArticles.first.id;
      expect(newFirst, isNot(equals(initialFirst)));
    });

    test('prevents deleting category when articles are attached', () async {
      final controller = Get.put(ArticlesController());
      await controller.loadData();

      final initialCatCount = controller.categories.length;
      // Category 'care' contains 3 articles
      expect(controller.countFor('care'), greaterThan(0));

      await controller.deleteCategory('care');
      // Should NOT delete
      expect(controller.categories.length, initialCatCount);
      expect(controller.categories.any((c) => c.id == 'care'), isTrue);
    });

    test('allows deleting empty category', () async {
      final controller = Get.put(ArticlesController());
      await controller.loadData();

      await controller.addCategory(
        nameBn: 'খালি ক্যাটাগরি',
        nameEn: 'Empty Category',
      );
      expect(controller.categories.any((c) => c.id == 'empty_category'), isTrue);

      await controller.deleteCategory('empty_category');
      expect(controller.categories.any((c) => c.id == 'empty_category'), isFalse);
    });

    test('manages categories and tags', () async {
      final controller = Get.put(ArticlesController());
      await controller.loadData();

      final initialTagCount = controller.tags.length;
      await controller.addTag('testtag');
      expect(controller.tags.length, initialTagCount + 1);

      await controller.removeTag('testtag');
      expect(controller.tags.length, initialTagCount);
    });
  });

  group('ArticlesScreen Widget Tests', () {
    Future<void> pumpArticles(
      WidgetTester tester, {
      Size size = const Size(1440, 900),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Get.put(ArticlesController());
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ArticlesScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders category pane, list pane and details pane on desktop', (
      tester,
    ) async {
      await pumpArticles(tester);

      expect(find.text('Articles'), findsWidgets);
      expect(find.text('Categories & Tags'), findsOneWidget);
      expect(find.text('Add Article'), findsOneWidget);
    });

    testWidgets('switches between Articles and Categories & Tags tabs', (
      tester,
    ) async {
      await pumpArticles(tester);

      await tester.tap(find.text('Categories & Tags'));
      await tester.pumpAndSettle();

      expect(find.text('Article Categories & Topics'), findsOneWidget);
      expect(find.text('Tag Library'), findsOneWidget);
    });

    testWidgets('opens article editor when Add Article is tapped', (
      tester,
    ) async {
      await pumpArticles(tester);

      await tester.tap(find.text('Add Article'));
      await tester.pumpAndSettle();

      expect(find.text('New Article'), findsOneWidget);
      expect(find.textContaining('Bilingual Content'), findsOneWidget);
    });

    for (final size in const [
      Size(390, 844),
      Size(834, 1112),
      Size(1440, 900),
    ]) {
      testWidgets('renders without overflow at ${size.width.toInt()}x'
          '${size.height.toInt()}', (tester) async {
        await pumpArticles(tester, size: size);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
