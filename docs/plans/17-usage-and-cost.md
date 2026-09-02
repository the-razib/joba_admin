# 17 — Usage & Cost Section

**Goal:** Replace the synthetic seeded series with real Firebase usage/cost data from Cloud
Monitoring, served through a callable function, with a daily cached rollup in Firestore.

**Depends on:** `04-cloud-functions-foundation.md`
**Estimated scope:** medium

---

## Current state (verified)

- UI complete: `lib/features/usage/` — KPI grid, cost trend chart, free-tier quota bars,
  service breakdown, outlook/forecast, 7/30/90-day ranges.
- `UsageRepository` = `seedDailyUsage()` — 90 days of deterministic synthetic metrics
  (`Random(42)`, growth curves). All cost math is local against `FirebasePricing` constants in
  `lib/features/usage/models/usage_metrics.dart`.
- Repo doc comment already prescribes Phase 3: authenticated callable `getProjectUsage` querying
  Cloud Monitoring, cached daily rollup in Firestore.

---

## Architecture

```
Scheduled function (daily ~03:00)
  ├─ reads yesterday's metrics from Cloud Monitoring API
  │    (firestore.googleapis.com: document reads/writes/deletes,
  │     storage.googleapis.com: storage + egress,
  │     authentication: MAU / verifications,
  │     functions.googleapis.com: invocations)
  ├─ maps to UsageDay (keep the panel's existing model — it's good)
  └─ writes usage_daily/{yyyy-mm-dd}

Panel
  └─ reads usage_daily directly (plain docs; no function needed for reads)
     + callable adminGetProjectUsage for on-demand "today so far" refresh
```

Why: Cloud Monitoring API requires service credentials ⇒ function territory. Daily rollup keeps
panel reads at ≤90 doc reads for a 90-day view.

---

## Tasks

### Cloud Functions
- [ ] Enable **Cloud Monitoring API** on `joba-a913b`.
- [ ] Scheduled function `collectUsageDaily` (superAdmin not required — runs on schedule):
  fetch previous day's metric points, compute counts, cost per service using a **server-side copy**
  of pricing constants, write `usage_daily/{date}`. Backfill flag for manual runs.
- [ ] `adminGetProjectUsage` callable (fill plan-04 skeleton): returns latest metrics for a range;
      triggers a fresh collect for "today" if missing.
- [ ] Store pricing table in the function (single source); panel keeps its `FirebasePricing`
      constants for display math — add a comment to keep them in sync, OR have the function return
      costs and the panel only renders (preferred: panel stops computing costs).

### Panel side
- [ ] `FirebaseUsageRepository`: `seedDailyUsage()` → `fetchRange(days)` reading `usage_daily`
      docs ordered by date; map to existing `UsageDay`.
- [ ] Quota bars: free-tier quotas from existing `FirestoreFreeQuota` constants — fine to keep.
- [ ] Source note widget: change "simulated" wording to real source + last-updated timestamp
      from the newest rollup doc.
- [ ] Forecast/outlook: keep the local projection math but feed it real data.
- [ ] Controller: loading + empty states (first days after launch will be sparse — handle gaps:
      render missing days as zero, don't crash charts).
- [ ] Tests: unit tests for gap-filling + range slicing.

## Sathi AI Control dependency

The Sathi AI admin module uses a separate configuration and analytics contract. It must not
reuse `usage_daily` fields for model usage or store chat content in Firestore.

- Configuration: `app_config/sathi_ai`
- Daily analytics: `sathi_ai_usage_daily/{yyyy-mm-dd}`
- Optional per-user quota state: `sathi_ai_user_usage/{uid}`
- Admin mutations: append-only `audit_logs` entries
- Chat history: mobile-only Drift storage in v1

The Sathi AI dashboard may read pre-aggregated daily rollups only. It must not scan users or
chat messages to calculate KPIs. The provider model and price table remain server-controlled;
the panel renders returned rollup costs.

## Acceptance criteria

- [ ] Charts display real usage for days since launch (non-zero reads appear immediately —
      this very admin panel generates Firestore traffic).
- [ ] Rollup doc written daily by the scheduled function (verify 2 consecutive days).
- [ ] No synthetic data remains (remove `Random(42)` seeding code path).
- [ ] `flutter analyze` + `flutter test` clean; function tests green.
