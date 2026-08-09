/// Firebase consumption + cost models.
///
/// Field names deliberately mirror the Cloud Monitoring metric types they are
/// sourced from, so the Phase 3 repository is a mechanical mapping:
///
///   reads    -> firestore.googleapis.com/document/read_count
///   writes   -> firestore.googleapis.com/document/write_count
///   deletes  -> firestore.googleapis.com/document/delete_count
///   egress   -> firestore.googleapis.com/network/sent_bytes_count
///   stored   -> storage.googleapis.com/storage/total_bytes  (sampled daily)
///   objects  -> storage.googleapis.com/storage/object_count (sampled daily)
///
/// Cloud Monitoring reports *counts*, never money, so cost here is always
/// derived locally from [FirebasePricing]. Actual invoiced amounts only exist
/// in a BigQuery billing export.
library;

enum FirebaseService { firestore, storage, functions, hosting, auth }

/// Cost outlook for the current billing period.
enum CostOutlook { rising, stable, falling }

/// Blaze (pay-as-you-go) unit prices in USD. Defaults are the us-central1 /
/// nam5 list prices; other regions differ, so Phase 3 should read the region
/// from config rather than assuming these.
class FirebasePricing {
  const FirebasePricing({
    this.readPer100k = 0.06,
    this.writePer100k = 0.18,
    this.deletePer100k = 0.02,
    this.firestoreStoredGiBMonth = 0.18,
    this.storageStoredGiBMonth = 0.026,
    this.egressPerGiB = 0.12,
    this.functionsPerMillion = 0.40,
    this.hostingPerMonth = 0.0,
  });

  final double readPer100k;
  final double writePer100k;
  final double deletePer100k;
  final double firestoreStoredGiBMonth;
  final double storageStoredGiBMonth;
  final double egressPerGiB;
  final double functionsPerMillion;
  final double hostingPerMonth;

  static const usCentral = FirebasePricing();
}

/// Daily free allowance that still applies on Blaze. Exceeding it is what
/// turns a $0 project into a billed one, so the UI surfaces headroom.
class FirestoreFreeQuota {
  FirestoreFreeQuota._();

  static const reads = 50000;
  static const writes = 20000;
  static const deletes = 20000;
  static const storedBytes = 1024 * 1024 * 1024; // 1 GiB
}

const _bytesPerGiB = 1024 * 1024 * 1024;

/// One day of project-wide consumption.
///
/// Firestore exposes no per-collection breakdown in Cloud Monitoring, so these
/// are whole-project totals by design.
class UsageDay {
  const UsageDay({
    required this.date,
    required this.reads,
    required this.writes,
    required this.deletes,
    required this.firestoreStoredBytes,
    required this.storageStoredBytes,
    required this.storageObjects,
    required this.egressBytes,
    required this.functionInvocations,
  });

  final DateTime date;
  final int reads;
  final int writes;
  final int deletes;
  final int firestoreStoredBytes;
  final int storageStoredBytes;
  final int storageObjects;
  final int egressBytes;
  final int functionInvocations;

  int get storedBytes => firestoreStoredBytes + storageStoredBytes;

  /// Stored data is billed monthly, so a single day carries 1/30th of it.
  double _storageCost(FirebasePricing p) =>
      (firestoreStoredBytes / _bytesPerGiB * p.firestoreStoredGiBMonth +
          storageStoredBytes / _bytesPerGiB * p.storageStoredGiBMonth) /
      30;

  double firestoreCost(FirebasePricing p) =>
      reads / 100000 * p.readPer100k +
      writes / 100000 * p.writePer100k +
      deletes / 100000 * p.deletePer100k +
      firestoreStoredBytes / _bytesPerGiB * p.firestoreStoredGiBMonth / 30;

  double storageCost(FirebasePricing p) =>
      storageStoredBytes / _bytesPerGiB * p.storageStoredGiBMonth / 30 +
      egressBytes / _bytesPerGiB * p.egressPerGiB;

  double functionsCost(FirebasePricing p) =>
      functionInvocations / 1000000 * p.functionsPerMillion;

  double costUsd(FirebasePricing p) =>
      reads / 100000 * p.readPer100k +
      writes / 100000 * p.writePer100k +
      deletes / 100000 * p.deletePer100k +
      egressBytes / _bytesPerGiB * p.egressPerGiB +
      functionInvocations / 1000000 * p.functionsPerMillion +
      _storageCost(p);

  double costForService(FirebaseService s, FirebasePricing p) => switch (s) {
    FirebaseService.firestore => firestoreCost(p),
    FirebaseService.storage => storageCost(p),
    FirebaseService.functions => functionsCost(p),
    FirebaseService.hosting => p.hostingPerMonth / 30,
    // Firebase Auth is free below the Identity Platform tiers; only phone
    // verification bills, which this project does not use.
    FirebaseService.auth => 0,
  };
}

/// A metric measured against its daily free allowance.
class QuotaLine {
  const QuotaLine({
    required this.label,
    required this.used,
    required this.limit,
    required this.unitIsBytes,
  });

  final String label;
  final num used;
  final num limit;
  final bool unitIsBytes;

  double get fraction => limit == 0 ? 0 : (used / limit).clamp(0.0, 1.0);

  bool get isOver => used > limit;

  bool get isNear => !isOver && fraction >= 0.75;
}
