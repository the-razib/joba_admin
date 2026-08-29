# 09 — Avatars Section

**Goal:** Move profile avatars from bundled assets to Firestore + Storage so the app can receive
new avatar packs without app releases.

**Depends on:** `03-repository-foundation.md`
**Estimated scope:** small-medium

---

## Current state (verified)

- UI complete: `lib/features/avatars/` — category chips, grid, add-category dialog, multi-image
  upload flow (`upload_avatars_flow.dart`, `file_picker withData`), preview confirmation,
  toggle active/delete.
- Categories from `MockAvatarRepository.seedCategories()` (modern/simple/animal/hijab — matching
  bundled asset folders). Avatar items are **discovered at runtime from the asset manifest**
  (`assets/images/profile_avatars/{cat}/`).
- Uploads append in-memory `AvatarItem`s with `pendingBytes` — nothing is uploaded; lost on reload.

---

## Firestore + Storage schema

> ⚠️ **Reconcile with the mobile app first** — the app's avatar picker reads these; match field
> names and how the app caches avatar images offline (it downloads and caches; URLs must be stable).

```
avatar_categories/{id}
{ "name": "modern", "order": 1, "isActive": true }

avatars/{id}
{ "categoryId": "modern", "imageUrl": "https://firebasestorage...", "isActive": true,
  "order": 1, "createdAt": Timestamp }
```

Storage: `avatars/{categoryId}/{avatarId}.{ext}`.

---

## Tasks

- [ ] Extend `AvatarRepository`:
  ```dart
  Future<List<AvatarCategory>> categories();
  Future<void> addCategory(String name); toggleCategory(String id); deleteCategory(String id);
  Future<List<AvatarItem>> avatars({String? categoryId, bool activeOnly = false});
  Future<void> uploadAvatars(String categoryId, List<AvatarUpload> items); // bytes → Storage → docs
  Future<void> toggleAvatar(String id); Future<void> deleteAvatar(String id);
  ```
- [ ] `FirebaseAvatarRepository`:
  - `uploadAvatars`: sequential uploads with progress callback (the flow UI shows a preview-confirm
    step; surface per-file progress), then a `WriteBatch` of avatar docs.
  - `deleteAvatar`: remove Storage object best-effort + doc delete.
- [ ] Grid source switch: read from Firestore instead of the asset manifest. Keep the manifest
      reader only as a migration source.
- [ ] Migration: one-time upload of all bundled avatar assets into Storage + Firestore
      (script using the repo methods against emulator, verify, then production).
- [ ] Controller (`avatars_controller.dart`): real loading/progress states; remove in-memory-only
      behavior; disable category delete when it still contains avatars (confirm dialog).
- [ ] Mobile-side note: the app should list avatars per active category ordered by `order`,
      download on demand, and cache. If the mobile app still reads bundled assets only,
      file a task in the **mobile** plan to consume this collection.
- [ ] Tests: widget tests on mocks unchanged; unit test upload batching logic with fake storage.

## Acceptance criteria

- [ ] Uploaded avatars persist, appear in the grid, and are served from Storage URLs.
- [ ] Category management (add/toggle/delete) persists.
- [ ] Bundled packs migrated (all 4 categories live in Firestore).
- [ ] `flutter analyze` + `flutter test` clean.
