import 'dart:math';

import 'package:joba_admin/features/usage/models/usage_metrics.dart';

/// Phase 1: mock seed. Phase 3: `FirebaseUsageRepository` calls an
/// authenticated Cloud Function (`getProjectUsage`) that holds the service
/// account and queries Cloud Monitoring on the panel's behalf.
///
/// The service account key must never ship inside this app. Flutter Web serves
/// its bundle to the browser, so an embedded key would hand any visitor read
/// access to the whole GCP project. The callable verifies the caller's admin
/// claim, queries `monitoring.googleapis.com`, and caches the daily rollup in
/// Firestore so repeat panel loads do not re-bill Monitoring API reads.
abstract class UsageRepository {
  /// Newest day last. Callers slice the tail for shorter ranges.
  Future<List<UsageDay>> seedDailyUsage();
  Future<List<UsageDay>> fetchDailyUsage({int days = 90});
}

class MockUsageRepository implements UsageRepository {
  /// Seeded so the projection maths is stable across runs and tests.
  static const _seed = 42;
  static const _days = 90;

  @override
  Future<List<UsageDay>> seedDailyUsage() async {
    final rand = Random(_seed);
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);

    return [
      for (var i = _days - 1; i >= 0; i--)
        _dayAt(midnight.subtract(Duration(days: i)), _days - 1 - i, rand),
    ];
  }

  @override
  Future<List<UsageDay>> fetchDailyUsage({int days = 90}) async {
    final all = await seedDailyUsage();
    if (days >= all.length) return all;
    return all.sublist(all.length - days);
  }

  /// Compound growth plus weekend dips, so the trend and forecast have
  /// something realistic to read.
  ///
  /// Volumes are scaled to a ~50k MAU app: roughly $8/day ninety days ago
  /// rising to ~$14/day now. Anything smaller renders as a flat line pinned to
  /// the axis floor and prices every figure in fractions of a cent.
  ///
  /// Deletes are deliberately the one metric that stays inside the free tier —
  /// a period tracker appends far more than it removes — so the allowance card
  /// shows a mix rather than four identical maxed-out bars.
  UsageDay _dayAt(DateTime date, int index, Random rand) {
    final growth = pow(1.007, index).toDouble();
    final weekend =
        date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
    final seasonal = weekend ? 0.82 : 1.0;
    double jitter() => 0.93 + rand.nextDouble() * 0.14;

    final reads = (1650000 * growth * seasonal * jitter()).round();
    final writes = (340000 * growth * seasonal * jitter()).round();
    final deletes = (8400 * growth * seasonal * jitter()).round();

    // Stored data only ever grows; it is a cumulative sample, not a daily rate.
    final firestoreStored = (34 * 1024 * 1024 * 1024 * pow(1.005, index))
        .round();
    final storageStored = (240 * 1024 * 1024 * 1024 * pow(1.004, index))
        .round();

    return UsageDay(
      date: date,
      reads: reads,
      writes: writes,
      deletes: deletes,
      firestoreStoredBytes: firestoreStored,
      storageStoredBytes: storageStored,
      storageObjects: (186000 * pow(1.004, index)).round(),
      egressBytes: (38.0 * 1024 * 1024 * 1024 * growth * seasonal * jitter())
          .round(),
      functionInvocations: (2450000 * growth * seasonal * jitter()).round(),
    );
  }
}
