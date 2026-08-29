# 12 — Premium Section (Users, Promo Codes, Transactions)

**Goal:** Real premium analytics + promo code management. Today this section has **no repository
at all** — promos and transactions are hardcoded inline in the controller.

**Depends on:** `03-repository-foundation.md`
**Estimated scope:** medium

---

## Current state (verified)

- UI complete: `lib/features/premium/` — 3 tabs (premium users / promo codes / transactions),
  stats grid, create-promo dialog, toggle promo active.
- Premium users tab: filtered from `MockUserRepository.seedUsers()`.
- Promo codes (`SUMMER2026`, `WELCOME10`, `EID2026`) and transactions (`TX-1042` bKash 499 BDT,
  …) hardcoded in `PremiumController._load()`.

---

## Firestore schema

> ⚠️ **Reconcile with the mobile app's premium/billing implementation first.** The app owns
> purchase + redemption flows; the admin panel manages configuration and reads results.
> Bangladesh payments: bKash / Nagad / card — transactions must carry the gateway reference.

```
promo_codes/{code}
{
  "code": "EID2026",
  "discountPercent": 20,               // or discountAmount — match app logic
  "maxUses": 1000, "usedCount": 37,
  "perUserLimit": 1,
  "validFrom": Timestamp, "validUntil": Timestamp,
  "isActive": true,
  "appliesTo": ["monthly", "yearly"],  // plan ids the app sells
  "createdBy": "adminUid", "createdAt": Timestamp
}

transactions/{id}
{
  "uid": "...", "userName": "...",
  "plan": "monthly" | "yearly",
  "amount": 499, "currency": "BDT",
  "gateway": "bkash" | "nagad" | "card",
  "gatewayTxId": "...",
  "status": "pending" | "completed" | "failed" | "refunded",
  "promoCode": "EID2026",              // nullable
  "at": Timestamp
}
```

Composite indexes: transactions `status` + `at` DESC; `gateway` + `at` DESC.

---

## Tasks

- [ ] Create `lib/core/repositories/premium_repository.dart` (new interface):
  ```dart
  Future<PageResult<AppUser>> premiumUsers({...});     // reuse users query w/ plan filter
  Future<List<PromoCode>> promos();
  Future<void> createPromo(PromoCode p);
  Future<void> togglePromo(String code, bool active);
  Future<void> updatePromo(PromoCode p);
  Future<PageResult<Transaction>> transactions({TxStatus? status, String? gateway, ...});
  Future<PremiumStats> stats();   // totals via aggregate queries
  ```
- [ ] `FirebasePremiumRepository` implementation.
- [ ] Models: `PromoCode.toMap/fromMap`, `Transaction.toMap/fromMap` (plan 03 list).
- [ ] Controller (`premium_controller.dart`): delete the hardcoded seed lists entirely; wire tabs
      to repository; stats grid from aggregate queries (premium count, revenue sum, redemption rate).
- [ ] Create-promo dialog: validation (code format, dates, percent ≤ 100, maxUses ≥ 1);
      duplicate-code guard (`get(doc).exists` check).
- [ ] Redemption accounting: when the mobile app redeems a code it must
      `FieldValue.increment(1)` on `usedCount` — file this in the mobile plan; the admin reads it.
- [ ] Transactions are **written by payment flows** (app + gateway webhooks / Cloud Function if
      you add server-verified purchases later). Admin panel is read-only for transactions —
      no edit/delete in UI.
- [ ] Tests: unit tests for promo validation; widget tests on mocks unchanged.

## Acceptance criteria

- [ ] Premium users tab reflects real `plan == premium` users.
- [ ] Promo create/toggle persists; app-side redemption increments `usedCount` (verified with app).
- [ ] Transactions list shows real payment records with gateway references.
- [ ] Stats compute from aggregates, not hardcoded numbers.
- [ ] `flutter analyze` + `flutter test` clean.
