import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:joba_admin/features/dashboard/views/widgets/country_distribution_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_popular_articles_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_recent_reports_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_recent_users_card.dart';
import 'package:joba_admin/features/dashboard/views/widgets/dashboard_stats_grid.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

void main() {
  late MockUserRepository mockUsersRepo;
  late MockArticleRepository mockArticlesRepo;
  late MockReportRepository mockReportsRepo;
  late DashboardController controller;

  setUp(() async {
    Get.testMode = true;
    Get.put(ThemeService());
    Get.put(ShellController());
    mockUsersRepo = MockUserRepository();
    mockArticlesRepo = MockArticleRepository();
    mockReportsRepo = MockReportRepository();

    Get.put<UserRepository>(mockUsersRepo);
    Get.put<ArticleRepository>(mockArticlesRepo);
    Get.put<ReportRepository>(mockReportsRepo);

    controller = Get.put(DashboardController());
    await controller.loadDashboard();
  });

  tearDown(() {
    Get.reset();
  });

  group('DashboardController Dynamic Metrics Tests', () {
    test('calculates real dynamic KPI stats from loaded users', () {
      expect(controller.loading.value, isFalse);
      expect(controller.users.length, 12);
      expect(controller.totalUsersFormatted, '12');

      // Active today: users with lastActive within 24h
      final expectedActive = controller.users
          .where((u) => DateTime.now().difference(u.lastActive).inHours < 24)
          .length;
      expect(controller.activeTodayCount, expectedActive);
      expect(controller.activeTodayFormatted, expectedActive.toString());

      // Premium users
      final expectedPremium = controller.users
          .where((u) => u.plan == UserPlan.premium)
          .length;
      expect(controller.premiumUsersCount, expectedPremium);
      expect(controller.premiumUsersFormatted, expectedPremium.toString());

      // Average cycle length
      final sumCycle = controller.users
          .map((u) => u.averageCycleLength)
          .fold<int>(0, (a, b) => a + b);
      final expectedAvg = double.parse(
        (sumCycle / controller.users.length).toStringAsFixed(1),
      );
      expect(controller.avgCycleLength, expectedAvg);

      // KPI stats array has 5 tuples with non-empty strings
      final kpis = controller.kpiStats;
      expect(kpis.length, 5);
      expect(kpis[0].$2, 'Total Users');
      expect(kpis[0].$3, '12');
      expect(kpis[3].$2, 'Premium Users');
      expect(kpis[3].$3, expectedPremium.toString());
      expect(kpis[4].$2, 'Avg. Cycle Length');
      expect(kpis[4].$3, expectedAvg.toStringAsFixed(1));
    });

    test('calculates country donut slices dynamically from users', () {
      final slices = controller.countryDonutSlices;
      expect(slices, isNotEmpty);

      // Sum of percentages should approximately equal 100%
      final totalPct = slices.map((s) => s.value).fold<double>(0, (a, b) => a + b);
      expect(totalPct, closeTo(100.0, 1.0));

      // Bangladesh is majority in mock data
      expect(slices.any((s) => s.label == 'Bangladesh'), isTrue);
    });

    test('popular articles, recent users, and recent reports all take 4 items', () {
      expect(controller.recentUsers.length, 4);
      expect(controller.popularArticles.length, 4);
      expect(controller.recentReports.length, 4);
    });
  });

  group('Dashboard Widgets UI Tests', () {
    testWidgets('DashboardStatsGrid renders dynamic values from controller', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: DashboardStatsGrid(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatCard), findsNWidgets(5));
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('12'), findsOneWidget); // Real count, not static 24,789
      expect(find.text('Avg. Cycle Length'), findsOneWidget);
    });

    testWidgets('CountryDistributionCard renders dynamic centerValue', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: CountryDistributionCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Users by Country'), findsOneWidget);
      expect(find.text('12'), findsOneWidget); // Real center count, not static 24,789
    });

    testWidgets('Bottom row cards render 4 items each and match heights with IntrinsicHeight', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: DashboardRecentUsersCard()),
                    SizedBox(width: 16),
                    Expanded(child: DashboardPopularArticlesCard()),
                    SizedBox(width: 16),
                    Expanded(child: DashboardRecentReportsCard()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final usersCard = tester.getRect(find.byType(DashboardRecentUsersCard));
      final articlesCard = tester.getRect(find.byType(DashboardPopularArticlesCard));
      final reportsCard = tester.getRect(find.byType(DashboardRecentReportsCard));

      // All 3 cards must have the exact same height!
      expect(usersCard.height, equals(articlesCard.height));
      expect(articlesCard.height, equals(reportsCard.height));
    });
  });
}
