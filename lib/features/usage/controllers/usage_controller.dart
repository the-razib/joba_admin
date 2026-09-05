import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/usage_repository.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/usage/models/usage_metrics.dart';

class UsageController extends GetxController {
  final UsageRepository repo = Get.find<UsageRepository>();

  static const ranges = [7, 30, 90];

  final loading = true.obs;
  final daily = <UsageDay>[].obs;
  final rangeDays = 30.obs;
  final pricing = const FirebasePricing().obs;

  @override
  void onInit() {
    super.onInit();
    loadUsage();
  }

  Future<void> loadUsage() async {
    loading.value = true;
    AppLoggerHelper.info('[UsageController] 📈 Loading usage telemetry and cloud cost data...');
    try {
      final days = await repo.fetchDailyUsage(days: 90);
      daily.assignAll(days);
      AppLoggerHelper.success('UsageController', 'Loaded ${days.length} days of telemetry data');
    } catch (e, st) {
      AppLoggerHelper.failure('UsageController', 'Error loading usage, falling back to seed: $e', error: e, stackTrace: st);
      final fallback = await repo.seedDailyUsage();
      daily.assignAll(fallback);
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshUsage() => loadUsage();

  void setRange(int days) => rangeDays.value = days;

  /// Newest last, trimmed to the selected range.
  List<UsageDay> get window {
    final list = daily;
    if (list.length <= rangeDays.value) return list.toList();
    return list.sublist(list.length - rangeDays.value);
  }

  UsageDay? get latest => daily.isEmpty ? null : daily.last;

  DateTime? get lastUpdated => latest?.date;

  /// The window immediately before [window], used for period-over-period
  /// deltas. Empty when there is not enough history to compare fairly.
  List<UsageDay> get previousWindow {
    final size = window.length;
    final start = daily.length - size * 2;
    if (start < 0 || size == 0) return const [];
    return daily.sublist(start, daily.length - size);
  }

  int totalReads(List<UsageDay> d) => d.fold(0, (a, e) => a + e.reads);

  int totalWrites(List<UsageDay> d) => d.fold(0, (a, e) => a + e.writes);

  int totalDeletes(List<UsageDay> d) => d.fold(0, (a, e) => a + e.deletes);

  int totalEgress(List<UsageDay> d) => d.fold(0, (a, e) => a + e.egressBytes);

  double totalCost(List<UsageDay> d) =>
      d.fold(0.0, (a, e) => a + e.costUsd(pricing.value));

  double get windowCost => totalCost(window);

  List<double> get dailyCosts => [
    for (final d in window) d.costUsd(pricing.value),
  ];

  /// Percent change of this window's spend against the preceding one.
  /// Null when there is no comparable prior window.
  double? get costDeltaPercent {
    final prev = previousWindow;
    if (prev.isEmpty) return null;
    final before = totalCost(prev);
    if (before == 0) return null;
    return (windowCost - before) / before * 100;
  }

  double? _deltaOf(int Function(List<UsageDay>) metric) {
    final prev = previousWindow;
    if (prev.isEmpty) return null;
    final before = metric(prev);
    if (before == 0) return null;
    return (metric(window) - before) / before * 100;
  }

  double? get readsDeltaPercent => _deltaOf(totalReads);

  double? get writesDeltaPercent => _deltaOf(totalWrites);

  double? get egressDeltaPercent => _deltaOf(totalEgress);

  double? get storageDeltaPercent {
    final prev = previousWindow;
    if (prev.isEmpty || latest == null) return null;
    final before = prev.last.storedBytes;
    if (before == 0) return null;
    return (latest!.storedBytes - before) / before * 100;
  }

  /// Mean daily spend over the last 7 days — the basis for the forecast.
  double get recentDailyAverage {
    final list = daily.length <= 7
        ? daily.toList()
        : daily.sublist(daily.length - 7);
    if (list.isEmpty) return 0;
    return totalCost(list) / list.length;
  }

  /// Spend so far this calendar month.
  double get monthToDateCost {
    final now = DateTime.now();
    return totalCost(
      daily
          .where((d) => d.date.year == now.year && d.date.month == now.month)
          .toList(),
    );
  }

  int get daysRemainingInMonth {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return lastDay - now.day;
  }

  /// Month-to-date actual plus the recent daily average carried forward.
  double get projectedMonthCost =>
      monthToDateCost + recentDailyAverage * daysRemainingInMonth;

  CostOutlook get outlook {
    final delta = costDeltaPercent;
    if (delta == null || delta.abs() < 5) return CostOutlook.stable;
    return delta > 0 ? CostOutlook.rising : CostOutlook.falling;
  }

  /// Today's consumption against the daily free allowance that still applies
  /// on Blaze. Crossing these is what turns a $0 project into a billed one.
  List<QuotaLine> get quotas {
    final d = latest;
    if (d == null) return const [];
    return [
      QuotaLine(
        label: 'Document reads',
        used: d.reads,
        limit: FirestoreFreeQuota.reads,
        unitIsBytes: false,
      ),
      QuotaLine(
        label: 'Document writes',
        used: d.writes,
        limit: FirestoreFreeQuota.writes,
        unitIsBytes: false,
      ),
      QuotaLine(
        label: 'Document deletes',
        used: d.deletes,
        limit: FirestoreFreeQuota.deletes,
        unitIsBytes: false,
      ),
      QuotaLine(
        label: 'Stored data',
        used: d.firestoreStoredBytes,
        limit: FirestoreFreeQuota.storedBytes,
        unitIsBytes: true,
      ),
    ];
  }

  /// Breakdown of spend by individual service over the selected window.
  List<(FirebaseService, double)> get serviceCosts {
    final w = window;
    final p = pricing.value;
    return [
      for (final s in FirebaseService.values)
        if (s != FirebaseService.auth)
          (s, w.fold(0.0, (a, e) => a + e.costForService(s, p))),
    ].where((e) => e.$2 > 0).toList();
  }

  /// Share of spend by service over the selected window.
  Map<FirebaseService, double> get serviceSpend {
    final w = window;
    final p = pricing.value;
    final map = <FirebaseService, double>{};
    for (final s in FirebaseService.values) {
      map[s] = w.fold(0.0, (a, e) => a + e.costForService(s, p));
    }
    return map;
  }

  /// Verdict banner copy: free-tier status, estimated invoice, and drivers.
  String get plainLanguageVerdict {
    final projected = projectedMonthCost;
    if (projected < 0.01) {
      return 'Joba is operating fully within Firebase free quotas. Projected monthly bill: \$0.00.';
    }
    if (projected < 5.0) {
      return 'Minimal paid consumption. Projected monthly bill is approximately \$${projected.toStringAsFixed(2)}, driven mostly by Firestore document reads.';
    }
    return 'Active paid consumption. Projected monthly bill is approximately \$${projected.toStringAsFixed(2)}. Storage and document reads are the primary drivers.';
  }
}
