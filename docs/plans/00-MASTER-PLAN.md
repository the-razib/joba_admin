# Joba Admin Panel — Master Plan: Static UI → Dynamic Firebase

> Phase 1 (static UI with mock data) → Phase 3 (fully dynamic, Firebase-backed).
> This folder contains the complete, ordered execution plan. **Work through the files one by one, in order.**

---

## 1. Mission

Convert the `joba_admin` panel from hardcoded/mock data to live Firebase data for all 14 sections —
using the **same Firebase project and data model as the Joba mobile app** (project id: `joba-a913b`).

Key constraints:
- **No offline support needed** in the admin panel. It is an online-only tool. Do NOT add
  persistence/offline caches — just handle loading and error states cleanly.
- **No service-account secrets in the web bundle.** Anything requiring the Admin SDK
  (FCM sends, custom claims, Cloud Monitoring) must go through callable Cloud Functions.
- **UI stays untouched wherever possible.** The codebase was built with an intentional seam:
  controllers depend on repository *interfaces* bound in `_AppBindings` (`lib/main.dart`).
  Each plan swaps one `Mock*Repository` for a `Firebase*Repository` without rewriting UI code.
- **Cost awareness:** use server-side pagination (`limit` + `startAfter`), avoid blanket realtime
  listeners, prefer on-demand reads and pre-aggregated docs for analytics.

---

## 2. Current State Audit (verified)

| Fact | Status |
|---|---|
| Firebase packages in `pubspec.yaml` | **NONE** (no firebase_core, auth, firestore, storage, functions) |
| `Firebase.initializeApp()` | **Absent** — `lib/main.dart` doesn't even call `WidgetsFlutterBinding.ensureInitialized()` |
| `firebase_options.dart` | **Absent** |
| `.firebaserc` | Points to project `joba-a913b` (same as mobile app) |
| `firebase.json` | Hosting-only config (public `build/web`), already deployed |
| Firestore rules for admin | None here — rules file lives in the **mobile repo** (`firestore.rules`) |
| Repositories | 8 interfaces + Mock implementations in `lib/core/repositories/` |
| Repository writes | 7 of 8 interfaces are **seed-only** (no create/update/delete). Only `ScreenerRepository` has full CRUD |
| Model serialization | Only `ScreenerAdminModel` has `toMap/fromMap`. All others need it |
| Auth | Hardcoded demo accounts in `lib/core/services/auth_service.dart`; session lost on page refresh |
| Platforms | Web only in practice (`web/` configured; no windows/macos/linux folders) |
| Tests | 10 test files in `test/`, all built against mock repositories |

### Section status summary

| # | Section | UI | Data today | Plan file |
|---|---------|----|-----------|-----------|
| 1 | Auth / Login | ✅ complete | Hardcoded creds | `02-auth-and-admin-roles.md` |
| 2 | Dashboard | ✅ complete | Seeds + hardcoded chart series | `16-dashboard.md` |
| 3 | Users | ✅ complete | `MockUserRepository` seed | `06-users.md` |
| 4 | Cycle Data | ✅ complete | Aggregates over seed users | `07-cycle-data.md` |
| 5 | Disease Checkup (Screeners) | ✅ complete | In-memory CRUD (best prepared) | `05-disease-checkup-screeners.md` |
| 6 | Articles | ✅ complete (full editor) | Seed, in-memory writes, no uploads | `08-articles.md` |
| 7 | Avatars | ✅ complete | Asset scan + in-memory uploads | `09-avatars.md` |
| 8 | Reminders | ✅ complete | Fake save | `13-reminders-and-app-settings.md` |
| 9 | Push Notifications | ✅ complete | Mock dispatch | `11-push-notifications.md` |
| 10 | Reports | ✅ complete | Seed, in-memory status | `10-reports.md` |
| 11 | Premium | ✅ complete | Hardcoded promos/transactions, no repo | `12-premium.md` |
| 12 | App Settings | ✅ complete | Local Rx values, fake save | `13-reminders-and-app-settings.md` |
| 13 | Admin Management | ✅ complete | Hardcoded list, no repo | `14-admin-management.md` |
| 14 | Audit Logs | ✅ complete | Seed (read-only section) | `15-audit-logs.md` |
| — | Usage & Cost | ✅ complete | Synthetic seeded series | `17-usage-and-cost.md` |

---

## 3. Target Architecture

```
Flutter Web admin panel (GetX)
├── lib/core/services/
│   ├── auth_service.dart        → Firebase Auth + custom claims (role)
│   ├── firestore_service.dart   → configured Firestore instance + pagination helpers
│   ├── storage_service.dart     → upload bytes → download URL
│   └── functions_service.dart   → callable Cloud Function wrappers
├── lib/core/repositories/
│   ├── *_repository.dart        → interfaces (extended with CRUD + queries)
│   └── firebase_*_repository.dart → real implementations (one per section)
├── lib/main.dart  _AppBindings  → binds Firebase implementations (mocks kept behind a flag)
└── functions/ (TypeScript, Node)  → Admin-SDK work:
    ├── sendPush (FCM HTTP v1)
    ├── setAdminClaims / inviteAdmin
    ├── auditLogger helper (used by all admin write functions)
    └── getProjectUsage (Cloud Monitoring)
```

Firestore (single database shared with the mobile app — admin reads/writes the same collections):

```
users/{uid}                    — user profiles (written by app, managed by admin)
users/{uid}/cycles/{cycleId}   — cycle logs
users/{uid}/reports/{id}       — problem reports submitted by the app
articles, article_categories, article_tags
avatars, avatar_categories
screeners
promo_codes, transactions
push_campaigns
app_config/general, app_config/algorithm, app_config/reminders
admins/{uid}
audit_logs/{id}
usage_daily/{yyyy-mm-dd}
```

> ⚠️ Collection names/fields must be reconciled with the mobile app's actual schema
> (mobile repo: `Firebase Integration For Period Tracker.md`, `firestore.rules`,
> `lib/core/services/`). If a mismatch is found, the mobile app's live schema wins —
> update the admin side, never fork the data model.

---

## 4. Ground Rules for AI Agents Executing These Plans

1. **One plan file at a time.** Finish and verify it before starting the next. Respect the
   prerequisite chain in the table below.
2. **Read the current file before editing** — files may have changed since this plan was written.
3. **Keep existing patterns:** GetX (`GetxController`, `Obx`, `Get.lazyPut`), existing widgets in
   `lib/core/widgets/`, `AppToast` for feedback, `ConfirmDialog` for destructive actions.
   Do not introduce new state-management or UI libraries.
4. **Never put secrets in the web bundle.** No service-account JSON, no Admin SDK in Flutter code.
5. **Every plan ends with verification:** `flutter analyze` clean, `flutter test` green,
   manual check via `flutter run -d chrome`.
6. **Keep mocks testable:** widget tests bind mock repositories; never delete mock classes —
   they remain the test doubles.
7. **Audit log every admin mutation** once `04-cloud-functions-foundation.md` is done
   (via the shared audit helper).
8. Update the status column in this file as plans complete.

---

## 5. Execution Order

| Order | Plan file | Depends on | Status |
|-------|-----------|------------|--------|
| 1 | `01-firebase-bootstrap.md` | — | ⬜ not started |
| 2 | `02-auth-and-admin-roles.md` | 01 | ⬜ |
| 3 | `03-repository-foundation.md` | 01 | ⬜ |
| 4 | `04-cloud-functions-foundation.md` | 01 | ⬜ |
| 5 | `05-disease-checkup-screeners.md` | 03 | ⬜ |
| 6 | `06-users.md` | 03 | ⬜ |
| 7 | `07-cycle-data.md` | 06 | ⬜ |
| 8 | `08-articles.md` | 03 | ⬜ |
| 9 | `09-avatars.md` | 03 | ⬜ |
| 10 | `10-reports.md` | 03 | ⬜ |
| 11 | `11-push-notifications.md` | 03, 04 | ⬜ |
| 12 | `12-premium.md` | 03 | ⬜ |
| 13 | `13-reminders-and-app-settings.md` | 03 | ⬜ |
| 14 | `14-admin-management.md` | 02, 04 | ⬜ |
| 15 | `15-audit-logs.md` | 03, 04 | ⬜ |
| 16 | `16-dashboard.md` | 06, 08, 10 | ⬜ |
| 17 | `17-usage-and-cost.md` | 04 | ⬜ |
| 18 | `18-security-rules-and-hardening.md` | all above | ⬜ |

Notes:
- Plans 05–13 (sections) can be parallelized across developers/agents **after** 01–04, since each
  touches its own repository + controller. Do not run two plans that edit the same file concurrently.
- 05 (Screeners) is deliberately first among sections: it already has a full CRUD interface and
  serialized models — the fastest end-to-end win and the reference implementation for the rest.

---

## 6. Definition of Done (applies to every plan file)

- [ ] All tasks in the plan's checklist completed
- [ ] `flutter analyze` → 0 errors
- [ ] `flutter test` → all existing tests pass (updated where the plan says so)
- [ ] Manual verification steps in the plan pass on `flutter run -d chrome`
- [ ] No secrets committed; no `(mock)` toasts remaining in converted flows
- [ ] This master plan's status table updated
