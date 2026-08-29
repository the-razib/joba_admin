# 02 — Firebase Auth & Admin Roles

**Goal:** Replace hardcoded demo credentials with Firebase Authentication (email/password),
role-based access via custom claims, persistent sessions (survives page refresh), and role gating
in the UI.

**Depends on:** `01-firebase-bootstrap.md`
**Estimated scope:** medium

---

## Current state (verified)

- `lib/core/services/auth_service.dart`: hardcoded `demoAccounts`
  (`admin@joba.app/admin123` etc.), 600 ms fake delay, in-memory `Rx<AdminUser?>`.
- `lib/features/auth/auth_controller.dart` prefills admin credentials; login screen shows demo chips.
- `lib/routes/app_pages.dart`: `AuthGuard` redirects to `/login` when `AuthService.user.value == null`
  — because there is no session persistence, **every page refresh logs the user out**.
- Roles exist (`AdminRole` in `lib/features/admin_management/models/admin_user.dart`) but are barely
  enforced (`canManageContent` defined but unused; only `SettingsController.canEdit` and
  `AdminManagementController.canManageAdmins` check role).

---

## Tasks

### 2.1 Provision admin accounts & custom claims

- Create the initial admin users in Firebase console → Authentication (email/password):
  one super admin to start. Never hardcode passwords in the repo.
- Roles are delivered as Firebase **custom claims**: `{ role: 'superAdmin' | 'editor' | 'viewer' }`.
  Claims can only be set server-side — the callable function for this is built in plan 14
  (`setAdminClaims`). Until that exists, set claims once via a local Node script using
  `firebase-admin` (document it in `functions/scripts/` but never commit credentials).
- Create matching profile docs in Firestore: `admins/{uid}` →
  `{ name: string, email: string, role: string, active: bool, invitedBy?: string, createdAt: Timestamp }`.

### 2.2 Rewrite `AuthService`

Replace the mock implementation (keep the class name and public API surface controllers use):

```dart
class AuthService extends GetxService {
  final user = Rxn<AdminUser>();      // null = signed out
  final initializing = true.obs;      // auth state still resolving

  Future<void> init() async {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> signIn(String email, String password) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(...);
    // check admins/{uid} doc exists && active == true; else sign out + error
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  Future<AdminRole> _roleFor(User u) async {
    final claims = await u.getIdTokenResult();
    return AdminRole.fromString(claims.claims?['role']);
  }
}
```

Key behaviors:
- Load profile from `admins/{uid}` on sign-in; if the doc is missing or `active == false`,
  sign out and show "Account disabled / not authorized".
- `initializing` stays `true` until the first `authStateChanges` event — this fixes the
  refresh-logout bug.
- Re-read claims on `userChanges()` / token refresh so role changes apply without re-login
  (`user.getIdTokenResult(true)` after claim updates).

### 2.3 Fix `AuthGuard` for async auth

In `lib/routes/app_pages.dart`, the middleware must:
- If `AuthService.initializing.value == true` → show a splash/loading route (or block navigation)
  instead of redirecting to `/login`.
- Redirect to `/login` only when auth has resolved and user is null.
- Keep the `/login` route accessible when signed out.

### 2.4 Update `AdminUser` sourcing

`lib/features/admin_management/models/admin_user.dart` stays the UI model. Populate it from:
custom claim `role` + Firestore `admins/{uid}` fields (name, email, active, createdAt).
Remove hardcoded `uid` values like `adm-001` — use the real Firebase UID.

### 2.5 Enforce roles in UI

- `lib/features/shell/nav_items.dart`: hide the `administration: true` group
  (Settings, Admins, Audit) from `viewer`; hide Admin Management from `editor`.
- Activate the unused `canManageContent`: content sections (Articles, Avatars, Screeners, Push,
  Reminders) read-only for `viewer` — disable save/send/upload buttons
  (pass `enabled: authService.canManageContent` down; keep the widgets themselves unchanged).
- Settings screen: keep existing `canEdit` gating (now driven by real claims).
- Top-bar logout already works → point it at `AuthService.signOut()`.

### 2.6 Login screen cleanup

`lib/features/auth/login_screen.dart` + `auth_controller.dart`:
- Remove prefilled credentials.
- Demo-account chips: keep only behind `kDebugMode`, wired to real dev accounts if any, else remove.
- Real error messages: `wrong-password`, `user-not-found`, `too-many-requests`, `network`.
- Loading state on the button during sign-in.

### 2.7 Firestore access rule for `admins`

In the **mobile repo's** `firestore.rules` (single source of truth — coordinate with plan 18):

```
match /admins/{uid} {
  allow read: if isAdmin();           // request.auth.token.role != null
  allow write: if hasRole('superAdmin');
}
```

(Deploy rules in plan 18; until then, the panel works against test-mode rules.)

### 2.8 Update tests

- `test/login_test.dart`: bind a fake `AuthService` (or keep the old mock path behind a test flag);
  assert loading state, error display, and navigation on success.
- Add a small unit test for `AdminRole.fromString` claim parsing.

---

## Acceptance criteria

- [ ] Sign-in works with a real provisioned admin account; wrong password shows proper error.
- [ ] **Session survives browser refresh** (AuthGuard waits for auth to resolve).
- [ ] Disabled admin (`active: false`) cannot enter.
- [ ] Viewer role: administration nav items hidden; content sections read-only.
- [ ] No hardcoded credentials anywhere in `lib/` (grep for `admin123`).
- [ ] `flutter analyze` clean, `flutter test` green.

## Out of scope

- Admin invites/management UI wiring (plan 14), audit logging of logins (plan 15),
  MFA (possible later hardening in plan 18).
