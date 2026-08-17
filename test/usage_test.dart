import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/usage/models/usage_metrics.dart';
import 'package:joba_admin/core/repositories/usage_repository.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';
import 'package:joba_admin/features/usage/views/usage_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<UsageRepository>(MockUsageRepository());
  });

  tearDown(Get.reset);

  /// Constructed directly rather than through `Get.put`, so `onInit` never
  /// fires and the test owns `daily` outright.
  UsageDay day(
    DateTime date, {
    int reads = 100000,
    int writes = 25000,
    int deletes = 1000,
    int firestoreStoredBytes = 0,
    int storageStoredBytes = 0,
    int storageObjects = 0,
    int egressBytes = 0,
    int functionInvocations = 0,
  }) => UsageDay(
    date: date,
    reads: reads,
    writes: writes,
    deletes: deletes,
    firestoreStoredBytes: firestoreStoredBytes,
    storageStoredBytes: storageStoredBytes,
    storageObjects: storageObjects,
    egressBytes: egressBytes,
    functionInvocations: functionInvocations,
  );

  Future<void> pumpUsage(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Get.put(UsageController());
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: UsageScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('dataSizeLabel', () {
    test('scales past MB so storage totals stay readable', () {
      expect(dataSizeLabel(512), '512 B');
      expect(dataSizeLabel(1024 * 1024 * 1024 * 2), '2.00 GB');
      expect(dataSizeLabel(1024 * 1024 * 1024 * 1024 * 3), '3.00 TB');
    });

    test('never renders a four-digit MB value', () {
      // The pre-existing fileSizeLabel caps at MB, which is what would make
      // 1.6 GB of stored objects read as "1638.4 MB".
      expect(dataSizeLabel(1024 * 1024 * 1600), '1.56 GB');
    });
  });

  group('UsageController projection', () {
    test('carries the daily run rate forward instead of reporting the total '
        'so far', () {
      final c = UsageController();
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      // Every day of the current month up to today, all identical.
      c.daily.assignAll([
        for (var d = 1; d <= now.day; d++)
          day(DateTime(now.year, now.month, d)),
      ]);

      // Derived from the model, not the controller, so this is an independent
      // check that the controller composes per-day cost rather than inventing
      // its own arithmetic.
      final perDay = c.daily.first.costUsd(const FirebasePricing());

      expect(c.recentDailyAverage, closeTo(perDay, 1e-9));
      expect(c.monthToDateCost, closeTo(perDay * now.day, 1e-6));
      // A flat run rate projected across the month must land on the full
      // month's spend, whatever today's date happens to be.
      expect(c.projectedMonthCost, closeTo(perDay * daysInMonth, 1e-6));
    });
  });

  group('UsageController deltas', () {
    test('has no delta until a full prior window exists', () {
      final c = UsageController();
      c.daily.assignAll([
        for (var i = 0; i < 30; i++)
          day(DateTime(2026, 1, 1).add(Duration(days: i))),
      ]);
      c.setRange(30);

      expect(c.previousWindow, isEmpty);
      expect(c.readsDeltaPercent, isNull);
      expect(c.costDeltaPercent, isNull);
      expect(c.outlook, CostOutlook.stable);
    });

    test('compares the window against the one immediately before it', () {
      final c = UsageController();
      final start = DateTime(2026, 1, 1);
      c.daily.assignAll([
        for (var i = 0; i < 30; i++)
          day(start.add(Duration(days: i)), reads: 100000),
        for (var i = 30; i < 60; i++)
          day(start.add(Duration(days: i)), reads: 200000),
      ]);
      c.setRange(30);

      expect(c.readsDeltaPercent, closeTo(100, 1e-9));
      expect(c.writesDeltaPercent, closeTo(0, 1e-9));
      expect(c.outlook, CostOutlook.rising);
    });

    test('a shrinking window reads as falling', () {
      final c = UsageController();
      final start = DateTime(2026, 1, 1);
      // The prior window is daily[14..20], so the drop has to start at 21 for
      // the comparison to straddle it.
      c.daily.assignAll([
        for (var i = 0; i < 21; i++)
          day(start.add(Duration(days: i)), reads: 400000),
        for (var i = 21; i < 28; i++)
          day(start.add(Duration(days: i)), reads: 100000),
      ]);
      c.setRange(7);

      expect(c.outlook, CostOutlook.falling);
    });
  });

  group('UsageController quotas and split', () {
    test('flags the day that crosses the free allowance', () {
      final c = UsageController();
      c.daily.assignAll([
        day(DateTime(2026, 1, 1), reads: FirestoreFreeQuota.reads * 2),
      ]);

      final reads = c.quotas.firstWhere((q) => q.label == 'Document reads');
      expect(reads.isOver, isTrue);
      // The bar must not run past its track even when usage does.
      expect(reads.fraction, 1.0);
    });

    test('drops services that cannot bill', () {
      final c = UsageController();
      c.daily.assignAll([day(DateTime(2026, 1, 1))]);

      final services = c.serviceCosts.map((e) => e.$1);
      // Auth has no metered cost, so showing it as a $0.000 line is noise.
      expect(services, isNot(contains(FirebaseService.auth)));
      expect(services, contains(FirebaseService.firestore));
      expect(c.serviceCosts.every((e) => e.$2 > 0), isTrue);
    });
  });

  group('UsageScreen', () {
    testWidgets('answers reads, writes, storage and projected spend', (
      tester,
    ) async {
      await pumpUsage(tester);

      // 'Document reads'/'Document writes' appear both as a KPI and as a
      // free-allowance line, so match loosely on purpose.
      expect(find.text('Document reads'), findsWidgets);
      expect(find.text('Document writes'), findsWidgets);
      expect(find.text('Storage used'), findsOneWidget);
      expect(find.text('Projected this month'), findsOneWidget);
    });

    testWidgets('leads with a plain-language cost verdict', (tester) async {
      await pumpUsage(tester);

      // The whole point of the screen: is spend going up or not.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.startsWith('Spend is trending') == true ||
                  w.data?.startsWith('Spend is holding') == true),
        ),
        findsOneWidget,
      );
    });

    testWidgets('says the figures are estimates, not billed amounts', (
      tester,
    ) async {
      await pumpUsage(tester);

      expect(find.textContaining('estimated from list prices'), findsOneWidget);
      expect(find.textContaining('sampled once daily'), findsOneWidget);
    });

    for (final size in const [
      Size(390, 844),
      Size(834, 1112),
      Size(1440, 900),
    ]) {
      testWidgets('renders without overflow at ${size.width.toInt()}x'
          '${size.height.toInt()}', (tester) async {
        await pumpUsage(tester, size: size);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
