# 07 — Cycle Data Section

**Goal:** Replace client-side aggregates over seed users with real, privacy-respecting analytics
over the live user base and their cycle logs.

**Depends on:** `06-users.md` (needs the real users schema + query helpers)
**Estimated scope:** medium

---

## Current state (verified)

- UI complete: `lib/features/cycle_data/` — stats grid, cycle-length & age distributions, goals
  breakdown, user lookup, and a privacy banner (`cycle_privacy_banner.dart`) that already frames
  the sensitivity of this data.
- All numbers are computed client-side from the same 12 mock users. **There is no cycle-level data
  model in the admin panel at all** — only summary fields on `AppUser`.

---

## Data sources

> ⚠️ **Reconcile with the mobile app first.** Inspect the mobile repo's Drift tables and sync
> layer for cycles (likely `cycles` table synced to `users/{uid}/cycles/{cycleId}` or a
> `cycles` collection). The admin panel **never invents its own shape.**

Assumed layout:

```
users/{uid}                      → summary fields (avgCycleLength, avgPeriodLength, cycleCount,
                                   age, goals, countryCode)
users/{uid}/cycles/{cycleId}     → { startAt, endAt, cycleLength, periodLength, ... }
```

### Privacy rules (non-negotiable)

- This section shows **aggregates only**. No individual cycle rows in tables.
- User lookup returns summary fields, never raw cycle history, unless the mobile schema already
  grants admin read and the privacy banner workflow is followed.
- Keep the privacy banner visible; link it to the actual policy doc.

---

## Tasks

- [ ] Define `CycleAggregates` value object in `lib/features/cycle_data/models/` (avg/median cycle
      length, period length distributions, buckets, age buckets, goal counts, sample size).
- [ ] Aggregation strategy — choose the cheapest that works at current scale:
  1. **Small scale (< ~5k users):** compute aggregates with Firestore aggregate queries where
     possible (`AVG`, `COUNT`) + a bounded sampled read (e.g. first 1 000 users ordered by
     `createdAt`) for distribution buckets. Document the sampling.
  2. **Larger scale:** add a scheduled Cloud Function (plan-04 project) that pre-aggregates into
     `analytics/cycle_stats` doc daily; the panel then reads one document. Add the function here
     only when option 1 measurably strains read quota; otherwise file it as a note for plan 17.
- [ ] Distributions:
  - Cycle length buckets: 21–24, 25–28, 29–32, 33–35, irregular/other.
  - Age buckets: <18, 18–24, 25–34, 35+.
  - Goals: counts per goal string.
  All derived from `users` summary fields (no subcollection reads needed for these three).
- [ ] User lookup: reuse `FirebaseUserRepository.getByUid` from plan 06 (+ optional email query).
- [ ] Controller: replace seed computation; add loading + "sample size n = X" caption under each
      chart so aggregates are never mistaken for exact values.
- [ ] Cache aggregates in memory per session with a manual refresh button (avoid re-reading on
      every tab visit).
- [ ] Tests: unit tests for bucketing math with synthetic inputs.

## Acceptance criteria

- [ ] All stats derive from live Firestore data; sample size shown.
- [ ] Section never renders individual cycle records.
- [ ] Opening the section costs a bounded, documented number of reads/aggregates.
- [ ] Lookup finds a real user by UID/email.
- [ ] `flutter analyze` + `flutter test` clean.
