# 14 — Admin Management (Invites, Roles, Custom Claims)

**Goal:** Real admin lifecycle: list admins from Firestore, invite new admins (creates Auth user +
profile doc + custom claims via callable functions), change roles, deactivate.

**Depends on:** `02-auth-and-admin-roles.md`, `04-cloud-functions-foundation.md`
**Estimated scope:** medium

---

## Current state (verified)

- UI complete: `lib/features/admin_management/` — admins table with role badges, invite dialog,
  change role, toggle active; invite button gated to super admins.
- Data: **5 admins hardcoded in `AdminManagementController.onInit()`** — no repository.
  All mutations in-memory. Info banner already promises "Phase 3 enforces roles with Firebase
  custom claims".

---

## Architecture

Creating another admin requires the Admin SDK (create Auth user + set claims) ⇒ callable
functions (skeletons exist from plan 04):

```
Super admin (panel)
   └─ callable adminInviteAdmin { name, email, role, tempPassword }
        ├─ admin.auth().createUser({ email, password, displayName })
        ├─ admin.auth().setCustomUserClaims(uid, { role })
        ├─ firestore admins/{uid} = { name, email, role, active, invitedBy, createdAt }
        └─ audit log
   └─ callable adminSetRole { uid, role }        (also used by "change role")
        ├─ setCustomUserClaims + update admins doc
        └─ audit log
Deactivation = direct Firestore write admins/{uid}.active = false
   (sign-in check in AuthService rejects inactive admins — plan 02)
```

Security note: the invited person receives a **temporary password** that must be changed at first
login. Firebase has no forced-password-change flag on email/password — enforce it app-side:
store `mustChangePassword: true` in `admins/{uid}`; panel shows a forced "change password" screen
on login when set (Firebase Auth `updatePassword`).

---

## Firestore schema

```
admins/{uid}
{
  "name": "...", "email": "...",
  "role": "superAdmin" | "editor" | "viewer",
  "active": true,
  "mustChangePassword": true,
  "invitedBy": "adminUid",
  "lastSignInAt": Timestamp | null,
  "createdAt": Timestamp
}
```

---

## Tasks

### Cloud Functions (fill skeletons from plan 04)
- [ ] `adminInviteAdmin` — superAdmin only. Validate email format, role enum, no existing user
      with that email (`getUserByEmail` → error 'already exists'). Generate temp password if not
      provided (≥12 chars) and return it once in the response for the inviter to share.
- [ ] `adminSetRole` — superAdmin only. Prevent demoting/locking the **last active superAdmin**
      (count superAdmins first). Update claims + doc atomically (best effort).
- [ ] Both write audit logs with actor identity.

### Panel side
- [ ] New `AdminRepository` interface + `FirebaseAdminRepository`
      (`list`, `setActive`, `setRoleViaFunction`, `inviteViaFunction`); mock version too.
- [ ] Rewrite `AdminManagementController.onInit()` to fetch `admins` ordered by `createdAt`;
      delete the hardcoded list.
- [ ] Invite dialog: call function, then show the temp password once (copy button, warning that it
      won't be shown again); handle 'already exists' errors.
- [ ] Change role: confirm dialog (mention the user must re-login / token refresh for claim
      changes), call `adminSetRole`, refresh.
- [ ] Toggle active: direct write; deactivating yourself is blocked client-side AND by rules.
- [ ] Remove "(mock)" wording; role badge already exists.
- [ ] Rules (with plan 18): `admins` readable by any admin role; writes superAdmin-only;
      `request.auth.uid != target` for self-deactivation guard.
- [ ] Tests: widget tests on mocks; function unit tests for the last-superAdmin guard and
      duplicate-email handling.

## Acceptance criteria

- [ ] Invite flow creates a working login: new admin signs in with temp password, is forced to
      change it, lands with the correct role and gating.
- [ ] Role change takes effect (target admin's session refreshes claims or re-login applies it).
- [ ] Deactivated admin cannot sign in (plan-02 check) and disappears from active list.
- [ ] Last-superAdmin protection works.
- [ ] All actions audit-logged.
- [ ] `flutter analyze` + `flutter test` clean.
