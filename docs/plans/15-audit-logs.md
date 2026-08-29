# 15 — Audit Logs Section

**Goal:** Read real, server-written audit logs with server-side pagination and filters. The panel
never writes logs itself — logs are produced by Cloud Functions (plan 04 helper) so they are
tamper-proof.

**Depends on:** `03-repository-foundation.md`, `04-cloud-functions-foundation.md`
**Estimated scope:** small

---

## Current state (verified)

- UI complete: `lib/features/audit_logs/` — search, module/action filters, activity chart derived
  from data, stats grid, table + mobile cards, detail panel. Read-only section.
- `AuditLogRepository` = `seedLogs()` (14 logs incl. failed logins, IPs, locations).
- Doc comments already state: logs will be written by Cloud Functions.

---

## Firestore schema

```
audit_logs/{id}   (created only by Cloud Functions — deny all client writes in rules)
{
  "adminUid": "...", "adminEmail": "...",
  "module": "users" | "articles" | "avatars" | "screeners" | "push" | "promos" |
            "settings" | "admins" | "auth",
  "action": "create" | "update" | "delete" | "send" | "login" | "login_failed" | ...,
  "targetId": "...",             // nullable
  "summary": "Blocked user farhana@example.com",
  "meta": { },                   // nullable free-form (old/new diffs, counts, ...)
  "ip": "...", "location": "...",  // nullable; captured by functions where available
  "at": Timestamp
}
```

Composite index: `module` + `at` DESC; `action` + `at` DESC.
Optional TTL: Firestore TTL policy to auto-expire logs after 12–24 months (configure in plan 18
if retention policy allows).

---

## Tasks

- [ ] Extend `AuditLogRepository`:
  ```dart
  Future<PageResult<AuditLog>> page({String? module, String? action, String? search, ...});
  ```
- [ ] `FirebaseAuditLogRepository`: cursor pagination, `at DESC` ordering; search limited to
      `summary` prefix match (document limitation) or `adminEmail` exact match.
- [ ] Controller: replace `seedLogs()`; wire filters; stats grid from data page or small aggregate
      queries (e.g. log count per module for current page range — keep cheap).
- [ ] Activity chart: bucket the fetched window by day client-side (fine — bounded page sizes).
- [ ] Backfill: as each section plan (05–14) lands, verify its mutations produce audit entries;
      add any missing `writeAuditLog` calls in the corresponding functions. Also log
      **admin sign-in / failed sign-in** via an Auth-trigger function
      (`beforeSignIn`/`onLogin` in functions — record success + failure for admin emails only).
- [ ] Rules (plan 18): `allow read: if isAdmin(); allow write: if false;` (functions bypass rules).
- [ ] Tests: widget tests on mocks unchanged; unit test filter→query mapping.

## Acceptance criteria

- [ ] Every admin mutation performed in plans 05–14 shows up as a real log entry.
- [ ] Failed admin sign-ins are logged.
- [ ] Pagination + filters work server-side; no client writes to `audit_logs` possible.
- [ ] `flutter analyze` + `flutter test` clean.
