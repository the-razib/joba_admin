# 18 — Firestore Rules, Indexes & Security Hardening

**Goal:** Lock down the shared database for production: role-based rules, composite indexes,
App Check, and cost guardrails. Run this last, after sections are live.

**Depends on:** all previous plans (rules are written against the real access patterns)
**Estimated scope:** medium

---

## Current state (verified)

- Rules live in the **mobile repo** (`firestore.rules`) — single source of truth for the shared
  database. The admin repo has none.
- Admin panel today runs against whatever permissive rules the mobile app deployed.

---

## Tasks

### 18.1 Role-based rules (mobile repo's `firestore.rules`)

Helpers:

```js
function isSignedIn() { return request.auth != null; }
function isAdmin()    { return isSignedIn() && request.auth.token.role != null; }
function isAppUser()  { return isSignedIn() && request.auth.token.role == null; }
function hasRole(r)   { return isAdmin() && request.auth.token.role == r; }
function canEdit()    { return hasRole('superAdmin') || hasRole('editor'); }
```

Collection policy matrix (implement + verify each):

| Collection | App user | viewer | editor | superAdmin |
|---|---|---|---|---|
| `users/{uid}` (+ subcollections) | own doc RW | read | read | read |
| `users/{uid}` writes by admin | — | — | — | via rules or functions only |
| `articles`, `article_categories`, `article_tags` | read published | read | RW | RW |
| `avatars`, `avatar_categories` | read active | read | RW | RW |
| `screeners` | read active | read | RW | RW |
| `reports` | create own + read own | read | read+status | RW |
| `push_campaigns` | read in-app active | read | RW | RW |
| `promo_codes` | read active (validated server-side on redeem) | read | RW | RW |
| `transactions` | read own | read | read | read (no writes from client — payment flow) |
| `app_config/*` | read | read | read | RW |
| `admins/{uid}` | — | read | read | RW (+ no self-deactivate) |
| `audit_logs` | — | read | read | read (**write: false** — functions only) |
| `usage_daily`, `analytics/*` | — | read | read | read |

- App users get role-less tokens; admins get `role` claims — so `isAdmin()` vs `isAppUser()`
  cleanly separates the two apps.
- Validate every rule with the Firebase console **Rules Playground** before deploying:
  one positive + one negative case per row.
- Deploy: from the mobile repo, `firebase deploy --only firestore:rules`.

### 18.2 Composite indexes

Collect every index flagged during plans 05–17 (listed in each plan) into
`firestore.indexes.json` (mobile repo) and deploy: `firebase deploy --only firestore:indexes`.

### 18.3 App Check

- Enable App Check (reCAPTCHA v3) on the web admin app: add `firebase_app_check` package,
  activate in `main()`.
- Enforce in rules where practical (`request.appcheck != null` gated behind a feature flag during
  rollout so locked-out admins can recover).
- Enable on the mobile app too if not already (coordinate with mobile plan).

### 18.4 Storage rules

In the mobile repo's `storage.rules` (or admin-owned if split):
- Public read for `articles/**`, `avatars/**`, `screeners/**`, `push/**` (content delivery).
- Write: admins only (`request.auth.token.role != null`); no deletes for viewer/editor except own
  upload paths if any.

### 18.5 Cost & abuse guardrails

- Set **budget alerts** in Google Cloud Billing (50/80/100% of monthly target).
- Firestore usage alerts in the console.
- Rate limits: none native — rely on rules (no unbounded list reads: all admin list queries are
  `limit`-ed by code) + App Check.
- Review `usage_daily` weekly for the first month.

### 18.6 Final sweep

- [ ] Grep panel for leftover `(mock)` strings — all converted sections clean.
- [ ] Verify `USE_MOCKS=true` build still works (demo mode) and default build uses Firebase.
- [ ] Smoke-test all 14 sections in a production deploy (hosting) with all three roles.
- [ ] Document incident runbook in `docs/`: lock out a compromised admin (deactivate + claim
      removal + force sign-out via `revokeRefreshTokens`).

## Acceptance criteria

- [ ] Rules Playground: all matrix rows pass positive/negative tests.
- [ ] A signed-out client and an app-user token get `permission-denied` on every admin collection.
- [ ] Index deployment complete; no `failed-precondition` errors in any section.
- [ ] App Check enforced without locking out real admins.
- [ ] Budget alerts active.
