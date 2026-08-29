# 08 — Articles Section (Full CMS)

**Goal:** Make the bilingual article CMS real: Firestore CRUD for articles/categories/tags,
Firebase Storage for cover images and per-language audio, with the existing rich editor unchanged.

**Depends on:** `03-repository-foundation.md`
**Estimated scope:** large (biggest content section)

---

## Current state (verified)

- UI complete and rich: `lib/features/articles/` — 3-pane master-detail list, full editor screen
  (BN/EN title/subtitle/content, `rich_markdown_editor.dart`, image + per-language audio pickers,
  medical review fields, tags, SEO fields, status draft/review/published, featured flag,
  drag-reorder), category CRUD dialogs, tag management.
- `ArticleRepository` = seeds only (6 categories, 7 articles, 10 tags); every write is in-memory.
- `file_picker` results are stored on the model but **never uploaded**; `imagePath` stays an asset
  path. `Article` lacks `toMap/fromMap` (added in plan 03).

---

## Firestore schema

> ⚠️ **Reconcile with the mobile app first** — the app's article feature (with bookmarking and
> audio) reads these collections; field names must match exactly, including bilingual map keys
> (`bn` / `en`) and the published/featured flags used by the app's queries.

```
article_categories/{id}
{ "name": { "bn": "...", "en": "..." }, "order": 1, "isActive": true, "createdAt": Timestamp }

articles/{id}
{
  "title":       { "bn": "...", "en": "..." },
  "subtitle":    { "bn": "...", "en": "..." },
  "content":     { "bn": "...markdown...", "en": "...markdown..." },
  "categoryId": "fertility",
  "tags": ["pcos", "nutrition"],
  "imageUrl": "https://firebasestorage...",        // was imagePath
  "audio": { "bn": "https://...", "en": "https://..." },  // nullable per language
  "status": "draft" | "review" | "published",
  "featured": false, "order": 3,
  "medicalReview": { "reviewer": "...", "reviewedAt": Timestamp, "sources": ["..."] },
  "seo": { "metaTitle": {...}, "metaDescription": {...}, "keywords": [...] },
  "createdAt": Timestamp, "updatedAt": Timestamp, "updatedBy": "adminUid"
}
```

Storage layout: `articles/{articleId}/cover.{ext}`, `articles/{articleId}/audio_bn.{ext}`,
`articles/{articleId}/audio_en.{ext}`.

Composite indexes: `status` + `order`; `categoryId` + `order`.

---

## Tasks

### Collection wiring
- [ ] Extend `ArticleRepository` interface:
  ```dart
  Future<List<ArticleCategory>> categories();
  Future<void> addCategory(...); updateCategory(...); toggleCategory(...); deleteCategory(...);
  Future<PageResult<Article>> articles({String? categoryId, ArticleStatus? status, String? search, ...});
  Future<Article?> byId(String id);
  Future<void> saveArticle(Article a);       // create or update
  Future<void> deleteArticle(String id);
  Future<void> reorderArticles(List<String> orderedIds);  // batched order updates
  Future<List<String>> tags(); Future<void> addTag(...); removeTag(...);
  ```
- [ ] Implement `FirebaseArticleRepository`. `reorderArticles` → `WriteBatch` of `order` updates.
- [ ] Tags: store as `article_tags/{tag}` docs (single `tags` collection) rather than scattering
      them on articles only; articles reference tag ids.

### Media uploads
- [ ] Wire `ImageUploadField` bytes → `StorageService.upload(folder: 'articles/…/cover')`;
      store returned URL in `imageUrl`.
- [ ] Same for BN/EN audio via `AudioUploadField`; enforce size caps (e.g. image ≤ 2 MB,
      audio ≤ 10 MB) with clear validation messages; show upload progress
      (use `UploadTask` snapshots — extend `StorageService` with a streamed variant for this).
- [ ] On `deleteArticle`: delete the article's Storage folder (`listAll` + delete) best-effort;
      log failures but don't block the delete.

### Editor/controller
- [ ] `ArticlesController`: replace seeds with queries; loading states; dirty-check before
      navigating away from the editor (data is now valuable — prevent accidental loss).
- [ ] Status transitions: draft → review → published; only `published` is visible to the app.
      Prevent publishing when required bilingual fields are empty (reuse editor's validation).
- [ ] Preview images/audio from URLs (the preview widgets already exist — feed them URLs instead of
      asset paths; fall back to bundled assets for legacy seeded docs).
- [ ] Remove "(mock)" wording.

### Migration & tests
- [ ] One-time migration of the 7 seeded articles + categories + tags (they are real bilingual
      content): script or manual via the now-live editor, into emulator then production.
- [ ] Convert bundled-asset references (`assets/images/articles/…`) in migrated docs to Storage
      URLs; keep the assets only as offline fallback for the mobile app if it needs them.
- [ ] Tests: widget tests on mocks unchanged; add unit tests for reorder batching + validation.

## Acceptance criteria

- [ ] Create → edit → publish → reorder → delete all persist across reloads.
- [ ] Cover image + audio playable from Storage URLs in the admin preview.
- [ ] Mobile app article list/detail renders the published content (verify against the app build).
- [ ] Validation blocks publishing incomplete bilingual content.
- [ ] `flutter analyze` + `flutter test` clean.
