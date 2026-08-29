# 16 — Dashboard Section

**Goal:** Replace seed-based + hardcoded chart series with real KPIs aggregated from live data.

**Depends on:** `06-users.md`, `08-articles.md`, `10-reports.md` (dashboard reads their data)
**Estimated scope:** medium

---

## Current state (verified)

- UI complete: `lib/features/dashboard/` — stats grid, activity chart with range switch,
  country distribution donut, recent users/articles/reports lists, push banner.
- Data: seeds from User/Article/Report mock repos **plus hardcoded series**:
  `activityValues` (fixed lists per range) and `countrySlices`
  (`('Bangladesh', 78.4), ('India', 10.7), ...`).

---

## Data strategy (cost-conscious)

The dashboard is the most-visited screen — it must not cost a full table scan per visit.

**Tier 1 (now — while user count is small):** direct aggregate queries.
**Tier 2 (when reads grow):** a scheduled Cloud Function writes one pre-aggregated doc
`analytics/dashboard_snapshot` daily; dashboard = 1 read + light deltas. Implement Tier 2 only
when needed (note in code).

---

## Tasks

- [ ] Define `DashboardSnapshot` value object: totals (users, premium, articles, open reports),
      activity series (signups per day over 7/30/90d), country distribution, recents.
- [ ] Totals: `AggregateQuery.count()` on `users`, `users where plan==premium`, `articles where
      status==published`, `reports where status in (new, in_review, assigned)`.
- [ ] Activity chart (new users per day):
  - Query `users orderBy(createdAt)` limited to the selected range window; bucket by day
    client-side. Cap reads: `limit(1000)` per window; label chart "sampled" if capped.
  - Replace hardcoded `activityValues` completely.
- [ ] Country distribution: group the same fetched window by `countryCode`; replace hardcoded
      `countrySlices`.
- [ ] Recent users / articles / reports: `limit(5)` queries on each collection, ordered by
      `createdAt`/`updatedAt` DESC.
- [ ] Push banner: show count of `push_campaigns` with `status == 'draft'` (prompt to finish) —
      live query, or hide when zero.
- [ ] Cache the snapshot in memory (e.g. 5-minute TTL) with manual refresh button; never
      re-query on every tab switch.
- [ ] Controller: loading states per widget (skeletons already available in core widgets),
      empty-state for zero-data (fresh project).
- [ ] Tests: unit tests for day-bucketing and country grouping with synthetic docs.

## Acceptance criteria

- [ ] Every number on the dashboard comes from a live query (grep finds no hardcoded series).
- [ ] Range switch (7/30/90) changes the window without full re-read of unrelated data.
- [ ] Opening the dashboard costs a bounded, documented number of reads (list them in a code
      comment).
- [ ] `flutter analyze` + `flutter test` clean.
