import 'package:get/get.dart';
import 'package:joba_admin/features/usage/models/usage_metrics.dart';
import 'package:joba_admin/core/repositories/usage_repository.dart';

class UsageController extends GetxController {
  final UsageRepository repo = Get.find();

  static const ranges = [7, 30, 90];

  final loading = true.obs;
  final daily = <UsageDay>[].obs;
  final rangeDays = 30.obs;
  final pricing = const FirebasePricing().obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    daily.assignAll(await repo.seedDailyUsage());
    loading.value = false;
  }

  void setRange(int days) => rangeDays.value = days;

  /// Newest last, trimmed to the selected range.
  List<UsageDay> get window {
    final list = daily;
    if (list.length <= rangeDays.value) return list.toList();
    return list.sublist(list.length - rangeDays.value);
  }

  UsageDay? get latest => daily.isEmpty ? null : daily.last;

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
        label: 'Firestore stored',
        used: d.firestoreStoredBytes,
        limit: FirestoreFreeQuota.storedBytes,
        unitIsBytes: true,
      ),
    ];
  }

  /// Window spend split by service, largest first.
  List<(FirebaseService, double)> get serviceCosts {
    final out = [
      for (final s in FirebaseService.values)
        (
          s,
          window.fold<double>(
            0,
            (a, d) => a + d.costForService(s, pricing.value),
          ),
        ),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return out.where((e) => e.$2 > 0).toList();
  }
}
