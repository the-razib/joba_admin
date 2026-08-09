import 'package:flutter_test/flutter_test.dart';
import 'package:joba_admin/core/models/article.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';

void main() {
  test('mock user seed provides table-ready data', () async {
    final users = await MockUserRepository().seedUsers();
    expect(users, isNotEmpty);
    for (final u in users) {
      expect(u.uid, isNotEmpty);
      expect(u.email, contains('@'));
    }
  });

  test('mock articles are bilingual, categorized and versioned', () async {
    final repo = MockArticleRepository();
    final articles = await repo.seedArticles();
    final categories = await repo.seedCategories();

    expect(articles, isNotEmpty);
    for (final a in articles) {
      expect(a.titleBn, isNotEmpty);
      expect(a.titleEn, isNotEmpty);
      expect(ArticleStatus.values.contains(a.status), isTrue);
      expect(a.version, greaterThanOrEqualTo(1));
      expect(categories.any((c) => c.id == a.categoryId), isTrue);
    }
  });
}
