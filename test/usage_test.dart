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
      expect(dataSizeLabel(1024 * 1024 * 1600), '1.56 GB');
    });
  });

  group('UsageDay serialization', () {
    test('round-trip serialization toMap and fromMap', () {
      final now = DateTime(2026, 9, 1);
      final item = UsageDay(
        date: now,
        reads: 5000,
        writes: 1200,
        deletes: 50,
        firestoreStoredBytes: 1024 * 1024 * 10,
        storageStoredBytes: 1024 * 1024 * 50,
        storageObjects: 100,
        egressBytes: 1024 * 1024 * 20,
        functionInvocations: 800,
      );

      final map = item.toMap();
      final deserialized = UsageDay.fromMap(map);

      expect(deserialized.reads, 5000);
      expect(deserialized.writes, 1200);
      expect(deserialized.deletes, 50);
      expect(deserialized.storageObjects, 100);
    });
  });

  group('UsageController projection', () {
    test('carries the daily run rate forward instead of reporting the total so far', () {
      final c = UsageController();
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      c.daily.assignAll([
        for (var d = 1; d <= now.day; d++)
          day(DateTime(now.year, now.month, d)),
      ]);

      final perDay = c.daily.first.costUsd(const FirebasePricing());

      expect(c.recentDailyAverage, closeTo(perDay, 1e-9));
      expect(c.monthToDateCost, closeTo(perDay * now.day, 1e-6));
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
      expect(reads.fraction, 1.0);
    });

    test('drops services that cannot bill', () {
      final c = UsageController();
      c.daily.assignAll([day(DateTime(2026, 1, 1))]);

      final services = c.serviceCosts.map((e) => e.$1);
      expect(services, isNot(contains(FirebaseService.auth)));
      expect(services, contains(FirebaseService.firestore));
      expect(c.serviceCosts.every((e) => e.$2 > 0), isTrue);
    });
  });

  group('UsageScreen Widget Tests', () {
    testWidgets('answers reads, writes, storage and projected spend', (
      tester,
    ) async {
      await pumpUsage(tester);

      expect(find.text('Document reads'), findsWidgets);
      expect(find.text('Document writes'), findsWidgets);
      expect(find.text('Storage used'), findsOneWidget);
      expect(find.text('Projected this month'), findsOneWidget);
    });

    testWidgets('leads with a plain-language cost verdict', (tester) async {
      await pumpUsage(tester);

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

    testWidgets('renders source note with live Firebase analytics info', (
      tester,
    ) async {
      await pumpUsage(tester);

      expect(find.textContaining('Firebase Blaze pricing'), findsOneWidget);
      expect(find.textContaining('tracked daily'), findsOneWidget);
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
