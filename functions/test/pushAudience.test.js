// Tests for the audience contract shared with the mobile app.
//
// Runs against the COMPILED output (`lib/`) with Node's built-in test runner, so
// it needs no extra dependencies and no ts-node. `npm test` builds first.
//
// These rules are what decides who receives a campaign, so a silent change here
// is the difference between reaching everybody and reaching nobody.

const test = require('node:test');
const assert = require('node:assert/strict');

const {
  PUSH_AUDIENCES,
  FCM_TOKENS_COLLECTION,
  PUSH_CAMPAIGNS_COLLECTION,
  DEFAULT_PUSH_LOCALE,
  resolveAudience,
  isKnownAudience,
  normalizeLocale,
  isPermanentTokenError,
} = require('../lib/services/pushAudience');

test('audience list matches the panel enum', () => {
  assert.deepEqual([...PUSH_AUDIENCES], [
    'all',
    'free',
    'premium',
    'bangladesh',
  ]);
});

test('collection names are stable', () => {
  // The mobile app writes to one and reads the other; renaming either breaks
  // both clients at once.
  assert.equal(FCM_TOKENS_COLLECTION, 'fcm_tokens');
  assert.equal(PUSH_CAMPAIGNS_COLLECTION, 'push_campaigns');
});

test('"all" targets every device with no filters', () => {
  const spec = resolveAudience('all');
  assert.deepEqual(spec.filters, []);
  assert.equal(typeof spec.label, 'string');
});

test('"free" and "premium" split on isPremium as a boolean', () => {
  const free = resolveAudience('free');
  const premium = resolveAudience('premium');

  assert.deepEqual(free.filters, [{ field: 'isPremium', value: false }]);
  assert.deepEqual(premium.filters, [{ field: 'isPremium', value: true }]);
  // Booleans, not strings: Firestore equality is type-strict, so 'false' would
  // match nothing.
  assert.equal(typeof free.filters[0].value, 'boolean');
  assert.equal(typeof premium.filters[0].value, 'boolean');
});

test('"bangladesh" filters on an uppercase ISO country code', () => {
  const spec = resolveAudience('bangladesh');
  assert.deepEqual(spec.filters, [{ field: 'countryCode', value: 'BD' }]);
});

test('every declared audience resolves', () => {
  for (const audience of PUSH_AUDIENCES) {
    const spec = resolveAudience(audience);
    assert.ok(Array.isArray(spec.filters), `${audience} has filters`);
    assert.ok(spec.label.length > 0, `${audience} has a label`);
  }
});

test('an unknown audience throws instead of silently targeting everyone', () => {
  // Falling through to "no filters" would blast the whole user base.
  assert.throws(() => resolveAudience('inactive7d'), /Unknown audience/);
  assert.throws(() => resolveAudience(''), /Unknown audience/);
});

test('isKnownAudience rejects non-strings and unknown values', () => {
  assert.equal(isKnownAudience('all'), true);
  assert.equal(isKnownAudience('premium'), true);
  assert.equal(isKnownAudience('active'), false);
  assert.equal(isKnownAudience(undefined), false);
  assert.equal(isKnownAudience(null), false);
  assert.equal(isKnownAudience(42), false);
});

test('locale normalisation defaults to Bengali', () => {
  assert.equal(DEFAULT_PUSH_LOCALE, 'bn');
  assert.equal(normalizeLocale('en'), 'en');
  assert.equal(normalizeLocale('bn'), 'bn');
  assert.equal(normalizeLocale(undefined), 'bn');
  assert.equal(normalizeLocale('fr'), 'bn');
  assert.equal(normalizeLocale('EN'), 'bn', 'matching is exact, not case-folded');
});

test('only permanent FCM errors mark a token for deletion', () => {
  assert.equal(
    isPermanentTokenError('messaging/registration-token-not-registered'),
    true,
  );
  assert.equal(
    isPermanentTokenError('messaging/invalid-registration-token'),
    true,
  );
  assert.equal(isPermanentTokenError('messaging/invalid-argument'), true);

  // Transient conditions must NOT delete healthy tokens — that would
  // permanently unsubscribe devices during an outage.
  assert.equal(isPermanentTokenError('messaging/server-unavailable'), false);
  assert.equal(isPermanentTokenError('messaging/internal-error'), false);
  assert.equal(isPermanentTokenError('messaging/quota-exceeded'), false);
  assert.equal(isPermanentTokenError('messaging/third-party-auth-error'), false);
  assert.equal(isPermanentTokenError(undefined), false);
});
