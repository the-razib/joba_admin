# 13 — Reminders & App Settings (Remote Config Documents)

**Goal:** Persist global reminder ordering and app configuration (algorithm + general settings)
in Firestore `app_config/*` documents that the mobile app reads at startup.

**Depends on:** `03-repository-foundation.md`
**Estimated scope:** small

Both sections are one plan because they share the same mechanism: **single config documents**
(cheapest possible Firestore usage — one read per app launch each).

---

## Current state (verified)

- **Reminders** (`lib/features/reminders/`): drag-reorder global reminder order (pad / period-prep /
  medicine), dirty detection, reset; `saveOrder()` is a fake 400 ms delay + "(mock)" toast.
  Usage stats derived from seed users.
- **App Settings** (`lib/features/app_settings/`): algorithm config card (version, confidence
  threshold, WMA weights, outlier factor, irregular variance, median fallback) + general card
  (maintenance mode, force update, min version, Sathi AI toggle, article audio toggle).
  Pure local Rx values; `save()` = fake delay + "(mock)" toast. Save gated to super admin;
  read-only banner for others (keep this).
- Comments say it mirrors the mobile app's `DynamicConfig` targeting
  `app_config/algorithm` + `app_config/general`.

---

## Firestore schema

> ⚠️ **Reconcile with the mobile app's config service first** (its `DynamicConfig` /
> settings-loader). Field names must match exactly — the app parses these docs.

```
app_config/general
{
  "maintenanceMode": false,
  "forceUpdate": false,
  "minSupportedVersion": "1.2.0",
  "sathiAiEnabled": true,
  "articleAudioEnabled": true,
  "updatedAt": Timestamp, "updatedBy": "adminUid"
}

app_config/algorithm
{
  "version": 3,
  "confidenceThreshold": 0.72,
  "wmaWeights": [0.4, 0.3, 0.2, 0.1],
  "outlierFactor": 1.5,
  "irregularVariance": 2.0,
  "medianFallback": true,
  "updatedAt": Timestamp, "updatedBy": "adminUid"
}

app_config/reminders
{
  "order": ["pad", "periodPrep", "medicine"],   // ReminderKind ids
  "updatedAt": Timestamp, "updatedBy": "adminUid"
}
```

---

## Tasks

- [ ] New `lib/core/repositories/config_repository.dart`:
  ```dart
  Future<Map<String, dynamic>> getDoc(String docId);      // 'general' | 'algorithm' | 'reminders'
  Future<void> saveDoc(String docId, Map<String, dynamic> data);
  ```
  `FirebaseConfigRepository` (set with merge) + `MockConfigRepository`.
- [ ] **Settings screen:** bind fields to fetched `general` + `algorithm` docs on load;
      `save()` writes both (WriteBatch); optimistic UI with revert on failure; keep super-admin
      gating; audit-log the change (after plan 15's wiring, log old→new diff in `meta`).
- [ ] **Reminders screen:** load order from `app_config/reminders`; save writes the doc;
      reset = restore last fetched server order; delete fake delay/toast.
- [ ] Usage stats on the reminders screen: switch from seed-derived to real aggregate counts
      (or hide the cards until users data is live — decide with plan 06 done).
- [ ] Validation: numeric ranges on algorithm fields (weights sum ≈ 1, threshold 0–1, version int);
      min version semver format. Block save with clear messages otherwise — a bad algorithm config
      breaks predictions for every user.
- [ ] Mobile-side (file in mobile plan): app reads these 3 docs at startup with GetStorage cache
      fallback (offline-first) and applies them (maintenance gate, force-update dialog,
      reminder order, algorithm params).
- [ ] Tests: unit tests for validation + mapping; widget tests on mocks unchanged.

## Acceptance criteria

- [ ] Settings save → visible in Firestore console → picked up by the mobile app on next launch.
- [ ] Reminder order persists and the app applies it.
- [ ] Invalid algorithm values cannot be saved.
- [ ] No "(mock)" toasts remain in either screen.
- [ ] `flutter analyze` + `flutter test` clean.
