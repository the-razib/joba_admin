# 11 — Push Notifications (FCM + In-App Campaigns)

**Goal:** Real campaign delivery: FCM sends via a callable Cloud Function (service account stays
server-side), in-app campaigns as Firestore documents the mobile app fetches, campaign history
persisted.

**Depends on:** `03-repository-foundation.md`, `04-cloud-functions-foundation.md`
**Estimated scope:** large

---

## Current state (verified)

- UI complete: `lib/features/push_notifications/` — stats grid (sent/delivered/opened/open-rate),
  channel filter, campaign table (draft/sent), bilingual composer (`push_composer.dart`: audience
  selection, channel push/in-app/both, FIAM-style layout picker, validation issues/warnings),
  live preview, detail panel, resend/delete.
- `PushRepository`: `seed()` (5 campaigns) + `dispatch()` returning deterministic mock counts.
  Its doc comment already mandates the correct architecture: **FCM via callable Cloud Function**
  (HTTP v1 needs a service-account key — must never ship in a web bundle) and **in-app campaigns
  as Firestore docs** (Firebase In-App Messaging has no creation API).
- Image is a raw HTTPS URL text field — no upload.

---

## Architecture

```
Admin panel
 ├─ saves campaign doc → push_campaigns/{id}
 ├─ (image upload → Storage)
 └─ calls callable adminSendPush(campaignId)
        └─ Cloud Function (firebase-admin)
              ├─ validates campaign + admin role
              ├─ builds FCM message per audience (topic / condition)
              ├─ sends via FCM HTTP v1
              ├─ writes result back (sentCount, failedCount, sentAt, messageId)
              └─ audit log
Mobile app
 ├─ FCM token registration + topic subscription per audience segment
 └─ reads push_campaigns where channel includes in-app → shows banners
```

---

## Firestore schema

> ⚠️ Reconcile audience/topic names with the mobile app's notification service (its topic
> subscriptions define valid audiences).

```
push_campaigns/{id}
{
  "title": { "bn": "...", "en": "..." },
  "body":  { "bn": "...", "en": "..." },
  "channel": "push" | "inApp" | "both",
  "audience": "all" | "active" | "premium" | "inactive7d" | ...,  // maps to FCM topic/condition
  "layout": "banner" | "modal" | "card",                            // in-app only
  "imageUrl": "https://...",          // nullable; Storage upload
  "action": { "type": "screen" | "url" | "none", "value": "..." },
  "status": "draft" | "scheduled" | "sending" | "sent" | "failed",
  "scheduledFor": Timestamp | null,
  "result": { "sent": 0, "failed": 0, "messageId": "...", "sentAt": Timestamp },
  "createdBy": "adminUid", "createdAt": Timestamp
}
```

---

## Tasks

### Cloud Function — `adminSendPush` (from plan-04 skeleton)
- [ ] Verify caller role ≥ editor (`requireAdmin`).
- [ ] Load campaign doc; reject unless `status == 'draft'` (or `scheduled`).
- [ ] Map `audience` → FCM topic/condition (keep the mapping table in the function, validated
      against the app's known topics).
- [ ] Send localized messages: include both `bn` and `en` payloads; use FCM `notification` +
      `data` (deep-link action) — match what the mobile app's message handler expects.
- [ ] Update campaign: `status: 'sending'` → `'sent'/'failed'` + `result` counts + audit log.
- [ ] Scheduled sends (optional in v1): a scheduled function scans
      `status == 'scheduled' && scheduledFor <= now` each 15 min — implement only if the composer
      exposes scheduling; otherwise mark TODO.

### Panel side
- [ ] `FirebasePushRepository`: campaign CRUD against `push_campaigns`
      (create draft, update draft, delete draft/sent-keep-history, resend = re-invoke function).
- [ ] Image URL field → `ImageUploadField` + `StorageService` (folder `push/`).
- [ ] `PushController.send()`: set `status: 'sending'`, call `FunctionsService.call('adminSendPush')`,
      refresh result; show real counts from `result`, remove mock determinism.
- [ ] Stats grid: derive from campaign docs (sent totals). Delivered/opened metrics are NOT
      available from FCM responses on HTTP v1 without Analytics/BigQuery export — label the cards
      honestly ("sent" real, "delivered/opened" not tracked yet) and note the upgrade path
      (Analytics export) as future work.
- [ ] Remove "(mock)" wording.

### Mobile-side dependencies (file in the mobile plan)
- [ ] App subscribes to the audience topics used here.
- [ ] App reads `push_campaigns` (in-app channel) with offline cache + dismissal tracking.
- [ ] App's FCM handler routes `data.action` deep links.

### Tests
- [ ] Function: unit tests for audience mapping + role guard (firebase-functions-test).
- [ ] Panel: widget tests on mocks unchanged.

## Acceptance criteria

- [ ] Campaign created → sent → real FCM message received on a test device (topic subscribed).
- [ ] In-app campaign doc renders in the mobile app.
- [ ] Failed send shows a real error, campaign marked `failed`, resend works.
- [ ] All sends audit-logged with admin identity.
- [ ] `flutter analyze` + `flutter test` clean; function tests green.
