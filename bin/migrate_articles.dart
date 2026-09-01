// ignore_for_file: avoid_print
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:joba_admin/core/repositories/firebase_article_repository.dart';
import 'package:joba_admin/firebase_options.dart';

/// One-time migration tool to seed initial bilingual medical articles & categories to Firestore.
/// Run via: `dart run bin/migrate_articles.dart` or `flutter run bin/migrate_articles.dart`
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 Initializing Firebase for Articles Migration...');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final repo = FirebaseArticleRepository();
  print('📦 Migrating initial categories, bilingual articles, and tags...');
  await repo.migrateInitialSeedData();
  print('✅ Migration completed successfully!');
}
