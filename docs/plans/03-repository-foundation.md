# 03 — Repository Foundation (Interfaces, Serialization, Pagination, Storage)

**Goal:** Build the shared data layer every section plan reuses: completed repository interfaces,
model serialization, Firestore query/pagination helpers, the Storage upload service, and the
binding-swap mechanism in `_AppBindings`.

**Depends on:** `01-firebase-bootstrap.md`
**Estimated scope:** medium-large (but no visible UI change yet)

---

## Current state (verified)

- `lib/core/repositories/` — 8 interfaces + `Mock*` implementations.
- 7 of 8 interfaces expose **seed/read methods only**; only `ScreenerRepository` has CRUD.
- Only `ScreenerAdminModel` has `toMap()/fromMap()`; every other model is missing serialization.
- Controllers paginate **in memory** (e.g. `UsersController.paged`), call `repo.seedX()` in `onInit`.
- `file_picker` selections stop at preview — bytes are never uploaded anywhere.
- `_AppBindings` (`lib/main.dart`) is the documented swap seam.

---

## Tasks

### 3.1 Model serialization (toMap / fromMap)

Add `toMap()` / `factory fromMap(Map<String, dynamic>)` to every model, with `DateTime` ↔
Firestore `Timestamp` conversion. Reference pattern: `lib/features/disease_checkup/models/screener_admin_model.dart`.

| Model | File | Notes |
|---|---|---|
| `AppUser` | `lib/features/users/models/app_user.dart` | enums ↔ string; keep `status`, `plan` |
| `Article`, `ArticleCategory` | `lib/features/articles/models/` | bilingual maps `{ 'bn': ..., 'en': ... }`; `imagePath` becomes `imageUrl` |
| `AvatarItem`, `AvatarCategory` | `lib/features/avatars/models/` | `pendingBytes` stays runtime-only, never serialized |
| `Report` | `lib/features/reports/models/report.dart` | status ↔ string |
| `AuditLog` | `lib/features/audit_logs/models/audit_log.dart` | read-only side |
| `PushNotification` | `lib/features/push_notifications/models/push_notification.dart` | rename to campaign doc mapping |
| `PromoCode`, `Transaction` | `lib/features/premium/models/premium.dart` | currently inline-hardcoded in controller |
| `AdminProfile` | `lib/features/admin_management/models/admin_profile.dart` | |
| `UsageDay` | `lib/features/usage/models/usage_metrics.dart` | |
| `ReminderTemplate` | `lib/features/reminders/models/reminder_template.dart` | |

Rules:
- Use `Timestamp.fromDate` / `.toDate()` — never store raw strings for dates.
- `fromMap` must tolerate missing fields (admin reads documents written by older app versions).
- Add unit tests: `toMap → fromMap` round-trip equality per model.

### 3.2 Firestore pagination & query helpers

Create `lib/core/services/firestore_query.dart`:

```dart
class PageResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDoc; // cursor for startAfter
  final bool hasMore;
}

Future<PageResult<T>> queryPage<T>({
  required Query<Map<String, dynamic>> query,
  required T Function(DocumentSnapshot) map,
  required List<Order> orderBy,   // needs matching composite indexes
  DocumentSnapshot? startAfter,
  int limit = 25,
});
```

- Controllers switch from in-memory paging to cursor paging (each section plan does this for its
  own controller; here we only build the helper).
- Note required composite indexes in each section plan; deploy them in plan 18.

### 3.3 Storage upload service

Create `lib/core/services/storage_service.dart`:

```dart
class StorageService {
  /// Uploads bytes, returns a long-lived download URL.
  Future<String> upload({
    required String folder,        // 'articles' | 'avatars' | 'push' | ...
    required String name,          // sanitized file name or generated uuid
    required Uint8List bytes,
    String? contentType,
  });
}
```

- Path convention: `{folder}/{yyyy-MM}/{uuid}_{name}`.
- Always set `contentType` (web serves correct MIME).
- Used later by: articles (cover image + BN/EN audio), avatars, push campaign images.
- Wire emulator connection under `USE_EMULATORS`.

### 3.4 Extend repository interfaces

For each of the 7 seed-only interfaces, add the write/query methods its section needs
(exact signatures specified in each section plan). General shape:

```dart
abstract class XRepository {
  Future<List<X>> fetch...(...);          // replaces seedX()
  Future<PageResult<X>> page(...);        // where tables need server paging
  Future<void> create(X x);
  Future<void> update(X x);
  Future<void> delete(String id);
}
```

- Keep existing method names where controllers use them to minimize controller churn,
  or rename and update all call sites in the same plan — never leave a half-renamed interface.
- **Mock implementations keep working** (they remain the test doubles) — add stub implementations
  of the new methods that mutate their in-memory lists.

### 3.5 Binding swap mechanism

In `lib/main.dart` `_AppBindings`, introduce a single switch:

```dart
final bool useMocks = const bool.fromEnvironment('USE_MOCKS', defaultValue: false);
Get.lazyPut<UserRepository>(() => useMocks ? MockUserRepository() : FirebaseUserRepository());
```

- In tests, pass `--dart-define=USE_MOCKS=true` (or keep binding mocks directly in test setup).
- Each section plan flips its own repository when its `Firebase*Repository` lands —
  **do not switch all repositories at once**.
- Never delete `Mock*` classes.

### 3.6 Error/loading conventions

- Controllers: keep existing `isLoading` / `RxList` patterns; add try/catch around repo calls with
  `AppToast.error(message)` (existing util in `lib/core/widgets/app_toast.dart` or utils).
- Map common `FirebaseException` codes (`permission-denied`, `unavailable`, `not-found`) to
  human-readable messages in one helper: `lib/core/services/firebase_errors.dart`.
- No silent failures: every failed mutation must surface a toast/dialog.

---

## Acceptance criteria

- [ ] All listed models serialize with Timestamp-safe round-trips (+ unit tests pass).
- [ ] `queryPage` helper works against a seeded emulator collection (manual or integration check).
- [ ] `StorageService.upload` returns a public download URL from emulator + production storage.
- [ ] Interfaces extended; mock implementations compile and tests still green.
- [ ] `USE_MOCKS` flag keeps the whole app on mock data when set.
- [ ] `flutter analyze` clean; `flutter test` green.

## Out of scope

- Actual section conversions (plans 05–17 each own their repository implementation).
