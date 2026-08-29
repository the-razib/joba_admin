# 04 — Cloud Functions Foundation

**Goal:** Set up the TypeScript Cloud Functions project and shared server-side machinery that
several sections require: Admin SDK access, admin-auth middleware, and the audit-log writer.
Web clients can never hold service-account credentials — everything Admin-SDK-shaped lives here.

**Depends on:** `01-firebase-bootstrap.md`
**Estimated scope:** medium

---

## Why functions are mandatory (not optional)

| Need | Why client-side is impossible |
|---|---|
| Send FCM pushes (plan 11) | FCM HTTP v1 requires a service account |
| Set custom claims / invite admins (plan 14) | `admin.auth().setCustomUserClaims` is Admin SDK only |
| Write trusted audit logs (plan 15) | Client-written logs are forgeable |
| Cloud Monitoring usage reads (plan 17) | Requires privileged APIs |

---

## Tasks

### 4.1 Initialize the functions project

In the `joba_admin` repo root:

```bash
firebase init functions
```

- Choose: TypeScript, Node 20 (or current LTS), `functions/` folder, npm.
- Update `firebase.json`: add `"functions"` config (source `functions`, runtime).
- Keep existing hosting config untouched.

> Decision: functions live in the **admin repo** (they are admin-driven server logic).
> The mobile repo keeps owning `firestore.rules`. Both deploy against the same project
> `joba-a913b` — never run blind `firebase deploy` (deploys everything); always scope:
> `firebase deploy --only functions` / `--only hosting` / `--only firestore:rules`.

### 4.2 Shared admin middleware

`functions/src/middleware/requireAdmin.ts`:

```ts
// Verifies "Authorization: Bearer <idToken>" on callable calls,
// loads custom claims, and enforces a minimum role.
export type Role = 'viewer' | 'editor' | 'superAdmin';
export const ROLE_RANK: Record<Role, number> = { viewer: 0, editor: 1, superAdmin: 2 };

export async function requireAdmin(req: CallableRequest, minRole: Role): Promise<AdminContext> {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in required');
  const role = (req.auth.token.role as Role) ?? null;
  if (!role || ROLE_RANK[role] < ROLE_RANK[minRole])
    throw new HttpsError('permission-denied', 'Insufficient role');
  return { uid, role, email: req.auth.token.email };
}
```

Every admin callable function starts with this. **No anonymous or app-user access** to admin
functions (also enforce role claims here — app users have no `role` claim).

### 4.3 Audit log writer

`functions/src/services/audit.ts`:

```ts
export async function writeAuditLog(entry: {
  adminUid: string; adminEmail: string;
  module: string;   // 'users' | 'articles' | 'push' | ...
  action: string;   // 'create' | 'update' | 'delete' | 'send' | ...
  targetId?: string; summary: string; meta?: Record<string, unknown>;
}) {
  await db.collection('audit_logs').add({
    ...entry,
    at: FieldValue.serverTimestamp(),
  });
}
```

- Every mutation function in later plans calls this before returning.
- `audit_logs` is append-only from functions; the admin panel only reads (plan 15).

### 4.4 Function skeletons (implementations live in their section plans)

Create typed, deployed-but-guarded skeletons so later plans only fill in logic:

| Function | Type | Min role | Implemented in |
|---|---|---|---|
| `adminSendPush` | callable | editor | plan 11 |
| `adminInviteAdmin` | callable | superAdmin | plan 14 |
| `adminSetRole` | callable | superAdmin | plan 14 |
| `adminGetProjectUsage` | callable | superAdmin | plan 17 |

Each skeleton: `requireAdmin` + `writeAuditLog` wired, body returns `unimplemented` until its plan.

### 4.5 Client wrapper

Create `lib/core/services/functions_service.dart`:

```dart
class FunctionsService {
  final _f = FirebaseFunctions.instance;
  Future<T> call<T>(String name, Map<String, dynamic> data) async {
    final res = await _f.httpsCallable(name).call(data);
    return res.data as T;
  }
}
```

- Map `FirebaseFunctionsException` codes to friendly errors (reuse `firebase_errors.dart` from plan 03).
- Emulator hookup under `USE_EMULATORS`.

### 4.6 Emulators & local workflow

- `firebase.json` emulators block was added in plan 01 — verify `functions` emulator starts.
- Documented dev loop:
  1. `firebase emulators:start`
  2. `flutter run -d chrome --dart-define=USE_EMULATORS=true`
- Add `npm run build && npm run serve` scripts in `functions/package.json`.

### 4.7 Deploy pipeline

```bash
cd functions && npm ci && npm run build && cd ..
firebase deploy --only functions
```

- Pin the Node runtime; commit `functions/package-lock.json`.
- After first deploy, smoke-test one skeleton callable from the browser console or a quick Dart test.

---

## Acceptance criteria

- [ ] `functions/` builds with `npm run build` with zero TS errors.
- [ ] All four skeleton callables deployed; each rejects unauthenticated calls and non-admin roles.
- [ ] `writeAuditLog` writes a doc visible in Firestore when a skeleton is invoked.
- [ ] `FunctionsService.call` works from the Flutter web app against emulators and production.
- [ ] Dev workflow (emulators + app) documented in `docs/plans/README-dev-loop.md` or this file's section 4.6.

## Out of scope

- Actual push sending, invite flow, usage metrics — implemented in plans 11, 14, 17.
