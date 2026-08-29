# 06 — Users Section

**Goal:** Replace the 12 hardcoded seed users with live `users/{uid}` data: server-side search,
filters, pagination, and real status/plan/block/delete writes.

**Depends on:** `03-repository-foundation.md`
**Estimated scope:** medium

---

## Current state (verified)

- UI complete: `lib/features/users/` — search, status/plan/country filters, sort, client-side
  pagination (10/page), slide-over `user_detail_panel.dart`, action buttons (view/edit/block/
  unblock/delete) with confirm dialog.
- `UserRepository` = `seedUsers()` only; writes (`updateStatus`, `updatePlan`, `remove`) mutate the
  in-memory list; toasts say "(mock)".
- `AppUser` model has **no** `toMap/fromMap` yet (added in plan 03).

---

## Firestore schema

Collection: `users/{uid}` — **written by the mobile app**; the admin panel is a manager, not owner.

> ⚠️ **Reconcile with the mobile app first.** Read the mobile repo's user model / auth service /
> `firestore.rules` and mirror every field name. Likely shape:

```jsonc
{
  "uid": "...", "name": "...", "email": "...", "phone": "...",
  "status": "active" | "blocked",
  "plan": "free" | "premium",
  "country": "Bangladesh", "countryCode": "BD",
  "goals": ["..."], "createdAt": Timestamp, "lastActiveAt": Timestamp,
  // cycle summary fields used by Cycle Data section:
  "avgCycleLength": 28, "avgPeriodLength": 5, "cycleCount": 12
}
```

### Required composite indexes (deploy in plan 18)

- `status` ASC + `createdAt` DESC
- `plan` ASC + `createdAt` DESC
- `countryCode` ASC + `createdAt` DESC

---

## Tasks

- [ ] Extend `UserRepository` interface:
  ```dart
  Future<PageResult<AppUser>> pageUsers({
    String? search, UserStatus? status, UserPlan? plan, String? countryCode,
    DocumentSnapshot? startAfter, int limit = 25,
  });
  Future<AppUser?> getByUid(String uid);
  Future<void> updateStatus(String uid, UserStatus status);
  Future<void> updatePlan(String uid, UserPlan plan);
  Future<void> block(String uid);      // sets status + optional 'blockedAt'
  Future<void> unblock(String uid);
  Future<void> delete(String uid);     // careful: see data policy below
  ```
- [ ] Implement `FirebaseUserRepository`:
  - Search: Firestore has no full-text search — implement as `orderBy('name')` +
    `startAt(search)/endAt(search + '\uf8ff')` for prefix search; document the limitation.
    (Email exact-match fallback: separate `getByEmail` query.)
  - Filters combine with the composite indexes above; if a filter combo lacks an index, catch the
    `failed-precondition` error and show the index-creation link Firestore returns (dev convenience).
  - `delete`: **soft delete by default** (`status: 'deleted'` + PII scrub fields cleared) — hard
    delete of a user also requires cleaning `users/{uid}` subcollections, which client SDK cannot do
    recursively. If true GDPR-style hard delete is needed, add callable `adminDeleteUser` in plan 04's
    functions project (recursive delete via Admin SDK). Implement the callable now if privacy policy
    demands it; otherwise ship soft delete + TODO.
- [ ] `UsersController`: replace `seedUsers()` with `pageUsers()`; convert filter/sort changes into
  new queries (debounce search 350 ms); cursor-based next/prev page using `PageResult.lastDoc`.
- [ ] Detail panel: fetch fresh `getByUid` on open; wire action buttons to real writes;
  remove "(mock)" toasts.
- [ ] Stats grid (`users_stats_grid.dart`): compute from real data — total via count query
  (`AggregateQuery.count()`), plan/status breakdowns via grouped aggregate queries
  (keep read count low: max 4 aggregate queries, not per-row).
- [ ] Seed cleanup: keep `MockUserRepository` for tests only.
- [ ] Tests: widget tests stay on mocks; add unit tests for filter→query building logic.

## Acceptance criteria

- [ ] Table shows real users with working search, all filters, and cursor pagination
      (page 2 ≠ page 1, no duplicates).
- [ ] Block/unblock/plan change persists and is visible after reload.
- [ ] Detail panel reflects live data.
- [ ] Read efficiency: opening the page costs ≤ (1 page query + ≤4 aggregates), verified in
      DevTools/console usage.
- [ ] `flutter analyze` + `flutter test` clean.
