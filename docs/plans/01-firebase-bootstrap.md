# 01 — Firebase Bootstrap (Admin Panel)

**Goal:** Make the admin panel a real Firebase client — packages installed, app configured for
project `joba-a913b`, Firebase initialized at startup. No feature work yet; everything must keep
working on mock data afterwards.

**Depends on:** nothing
**Estimated scope:** small

---

## Current state (verified)

- `pubspec.yaml` has **zero** Firebase packages.
- `lib/main.dart` → `main()` runs `Get.put(ThemeService()); Get.put(AuthService()); runApp(...)`.
  No `WidgetsFlutterBinding.ensureInitialized()`.
- No `lib/firebase_options.dart`; `web/index.html` is the stock Flutter template.
- `.firebaserc` already targets `joba-a913b`; `firebase.json` is hosting-only.

---

## Tasks

### 1.1 Add dependencies

In `pubspec.yaml`:

```yaml
  # Firebase
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0
  cloud_functions: ^5.3.0
```

> Verify current compatible major versions against the Flutter SDK in use (`flutter --version`)
> and the mobile app's `pubspec.lock` (same Firebase project ⇒ keep SDK generations aligned).
> Then `flutter pub get`.

### 1.2 Generate Firebase configuration

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=joba-a913b --platforms=web --yes
```

- Generates `lib/firebase_options.dart`.
- If the CLI prompts for an existing app, select/reuse the **existing Web app** registered for the
  mobile project's Firebase project (check Firebase console → Project settings → Your apps).
  Do NOT create a second Firebase *project*. A separate Web *app* inside `joba-a913b` is fine and
  recommended for clean analytics attribution.
- Commit `firebase_options.dart` (it contains public web config only — API key is not a secret on web).

### 1.3 Initialize Firebase in `main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(ThemeService());
  Get.put(AuthService());
  runApp(const JobaAdminApp());
}
```

- Keep `_AppBindings` exactly as-is in this plan (mocks stay bound).
- If `Firebase.initializeApp` throws (e.g. no network), show a minimal error screen with a retry
  button instead of a white page — wrap in try/catch and surface via a small `FirebaseBootstrap`
  widget or a simple `runApp(ErrorScreen)`.

### 1.4 Central Firestore access point

Create `lib/core/services/firestore_service.dart`:

```dart
class FirestoreService {
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  /// Online-only admin panel: no persistence, sane cache cap.
  static void configure() {
    db.settings = const Settings(
      cacheSizeBytes: 20 * 1024 * 1024, // memory cache only, bounded
    );
  }
}
```

Call `FirestoreService.configure()` right after `Firebase.initializeApp`.
Explicitly: **no `enablePersistence`** — the admin panel is online-only by design.

### 1.5 Emulator support (for safe local development)

Add to `firebase.json` (admin repo):

```json
"emulators": {
  "auth": { "port": 9099 },
  "firestore": { "port": 8080 },
  "storage": { "port": 9199 },
  "functions": { "port": 5001 },
  "ui": { "enabled": true, "port": 4000 },
  "singleProjectMode": true
}
```

In `FirestoreService.configure()` (and later auth/storage services), connect to emulators when a
flag is set:

```dart
const useEmulators = bool.fromEnvironment('USE_EMULATORS', defaultValue: false);
```

Run with: `flutter run -d chrome --dart-define=USE_EMULATORS=true` + `firebase emulators:start`.

### 1.6 Hosting headers sanity check

`firebase.json` already has SPA rewrites + cache headers. After the first Firebase-enabled build,
deploy once to confirm hosting still works:

```bash
flutter build web --release
firebase deploy --only hosting
```

---

## Acceptance criteria

- [ ] `flutter pub get` succeeds; app compiles for web.
- [ ] On startup, Firebase initializes against `joba-a913b` (verify in DevTools network tab /
      Firebase console usage graph).
- [ ] App boots with init failure handled (airplane-mode test → friendly error + retry).
- [ ] All 14 sections still render exactly as before (mock data unaffected).
- [ ] `flutter analyze`: 0 errors. `flutter test`: all pass.
- [ ] Emulator flag works: `USE_EMULATORS=true` routes Firestore/Auth/Storage to local emulators.

## Out of scope (handled later)

- Real authentication (plan 02), repository swaps (03+), security rules (18).
