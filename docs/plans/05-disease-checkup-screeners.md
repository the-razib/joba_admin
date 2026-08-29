# 05 — Disease Checkup (Screeners) — First Dynamic Section

**Goal:** Wire the admin screener manager to Firestore end-to-end. This is the best-prepared section
(full CRUD interface + serialized models) and becomes the **reference implementation** for all
other sections.

**Depends on:** `03-repository-foundation.md`
**Estimated scope:** small

---

## Current state (verified)

- `lib/features/disease_checkup/` — complete UI: list pane, question editor, risk-tier editor,
  reorder, toggle active, KPI stats.
- `ScreenerRepository` already defines full CRUD: `getScreeners`, `getScreenerById`, `createScreener`,
  `updateScreener`, `deleteScreener`, `toggleScreenerActive`.
- `MockScreenerRepository` holds 4 clinical screeners (PCOS, Endometriosis, PMDD, Heavy Bleeding)
  in memory; mutations lost on reload.
- `ScreenerAdminModel` (+ nested question/risk-tier classes) already has `toMap/fromMap`.

---

## Firestore schema

Collection: `screeners/{screenerId}`

> ⚠️ **Reconcile with the mobile app** before starting: open the mobile repo's disease-checkup
> service/repository (`lib/features/disease_checkup/`) and match the collection name and field
> names exactly (the app reads this data offline-first; the admin must write what the app expects).

```jsonc
{
  "id": "pcos",                      // doc id = screener id
  "title": { "bn": "...", "en": "..." },
  "description": { "bn": "...", "en": "..." },
  "imageUrl": "https://firebasestorage...",
  "isActive": true,
  "order": 1,
  "questions": [ /* mirrors ScreenerAdminModel.toMap() shape */ ],
  "riskTiers": [ /* mirrors ScreenerAdminModel.toMap() shape */ ],
  "updatedAt": Timestamp,
  "updatedBy": "adminUid"
}
```

Storage: `screeners/{screenerId}/cover.{ext}` for `imagePath`.

---

## Tasks

- [ ] Create `lib/core/repositories/firebase_screener_repository.dart` implementing
      `ScreenerRepository` against the schema above:
  - `getScreeners()` → `orderBy('order')` full read (screeners are few; no paging needed).
  - Writes: `set`/`update`/`delete` + `updatedBy` from `AuthService`, `updatedAt: FieldValue.serverTimestamp()`.
  - `toggleScreenerActive` → single-field `update`.
- [ ] Replace the model's `imagePath` usage: add `imageUrl` (keep `imagePath` as display field fed
      from the URL); upload new images via `StorageService` before `create/update`.
- [ ] Swap the binding in `_AppBindings` (respecting the `USE_MOCKS` flag from plan 03).
- [ ] Controller changes (`admin_screener_controller.dart`): replace artificial delays with real
      loading states; surface save/delete errors via `AppToast`; refresh list after mutations.
- [ ] Remove "(mock)" wording from this feature's toasts/dialogs.
- [ ] Seed migration: one-time script or manual import of the 4 mock screeners into Firestore
      (emulator first, then production) — the mock list is high-quality clinical content; keep it.
- [ ] Audit: log create/update/delete/toggle via the plan-04 audit helper if functions are deployed,
      else add a TODO marker (audit wiring is finalized in plan 15).
- [ ] Tests: keep existing widget test on mocks; add a repository unit test using
      `fake_cloud_firestore` (add as dev dependency) or emulator-based test.

## Acceptance criteria

- [ ] CRUD persists across browser reloads (production Firestore, not emulator).
- [ ] Image upload produces a Storage object + working URL in the app-facing document.
- [ ] Mobile app (already released build or dev build) can read the screeners unchanged.
- [ ] Viewer role can browse but not edit (role gating from plan 02 applies).
- [ ] `flutter analyze` + `flutter test` clean.
