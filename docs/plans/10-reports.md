# 10 — Reports Section

**Goal:** Show real user-submitted problem reports and make status changes persist.

**Depends on:** `03-repository-foundation.md`
**Estimated scope:** small

---

## Current state (verified)

- UI complete: `lib/features/reports/` — type tabs (bug/prediction/content/feature/payment),
  search, status filter, stats grid, detail panel with timeline, status dropdown, "Assign to Team"
  (currently toast-only).
- `ReportRepository` = `seedReports()` (6 items); `updateStatus` mutates memory.
- Reports are written by the mobile app's "Report a Problem" screen.

---

## Firestore schema

> ⚠️ **Reconcile with the mobile app's report submission code first** — field names must match.

```
users/{uid}/reports/{reportId}         (if app nests under user)
   — or —
reports/{reportId}                     (flat, with uid field)
{
  "uid": "...", "userName": "...", "userEmail": "...",
  "type": "bug" | "prediction" | "content" | "feature" | "payment",
  "status": "new" | "in_review" | "assigned" | "resolved" | "closed",
  "message": "...", "appVersion": "...", "platform": "android",
  "device": "...", "os": "...",
  "assignedTo": "...",                       // nullable
  "createdAt": Timestamp, "updatedAt": Timestamp,
  "history": [ { "status": "...", "at": Timestamp, "by": "adminUid" } ]
}
```

Composite index: `type` + `createdAt` DESC; `status` + `createdAt` DESC.

---

## Tasks

- [ ] Confirm the app's write path (subcollection vs flat collection) from the mobile repo;
      implement the admin read against that exact path.
- [ ] Extend `ReportRepository`:
  ```dart
  Future<PageResult<Report>> page({ReportType? type, ReportStatus? status, String? search, ...});
  Future<void> updateStatus(String id, ReportStatus s, {String? assignedTo});
  ```
- [ ] `FirebaseReportRepository`: status update also appends to `history` (the detail panel's
      timeline renders directly from it — no separate model needed).
- [ ] Controller: cursor pagination, filter → query, stats via aggregate queries (count per status).
- [ ] "Assign to Team": implement as `status: assigned` + `assignedTo` text (free-form admin name
      for now; integrate with `admins` list from plan 14 later if desired).
- [ ] Remove "(mock)" wording; empty states for no results.
- [ ] Tests: widget tests on mocks unchanged; unit test query building.

## Acceptance criteria

- [ ] Real reports submitted from the mobile app appear in the panel.
- [ ] Status changes + assignment persist and show in the timeline.
- [ ] Filters and pagination work server-side.
- [ ] `flutter analyze` + `flutter test` clean.
