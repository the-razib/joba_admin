/**
 * Push audience definitions — the contract shared with the mobile app.
 *
 * The mobile app writes one document per device to `fcm_tokens/{deviceId}`
 * carrying the segment fields below. Audiences are resolved HERE, server-side,
 * by querying those documents.
 *
 * Why token targeting instead of FCM topics:
 *  - A topic send returns only a message id. It cannot report how many devices
 *    received it, so the admin panel's "sent / failed" counters would be
 *    fiction. Token targeting returns a real per-device result.
 *  - Invalid tokens are reported back per device, so dead registrations can be
 *    pruned instead of accumulating forever.
 *  - Notification copy can be localised per recipient (a topic send carries one
 *    language for everybody).
 *  - Adding or changing an audience becomes a server-side query change rather
 *    than a mobile release that alters topic subscriptions.
 *
 * The cost is one document read per targeted device per campaign, which is
 * negligible at this app's scale.
 */

/** Audience values the admin composer can produce. Keep in sync with the Dart
 * `PushAudience` enum in the panel and `PushAudience` in the mobile app. */
export const PUSH_AUDIENCES = [
  'all',
  'free',
  'premium',
  'bangladesh',
] as const;

export type PushAudience = (typeof PUSH_AUDIENCES)[number];

/** Firestore collection holding one document per registered device. */
export const FCM_TOKENS_COLLECTION = 'fcm_tokens';

/** Firestore collection holding campaign documents. */
export const PUSH_CAMPAIGNS_COLLECTION = 'push_campaigns';

/** Languages the app ships. Notification copy is grouped by these. */
export type PushLocale = 'bn' | 'en';

/** Default locale, matching the app's default (bn_BD). */
export const DEFAULT_PUSH_LOCALE: PushLocale = 'bn';

/** A single equality filter to apply to the token collection. */
export interface AudienceFilter {
  field: string;
  value: string | boolean;
}

export interface AudienceQuerySpec {
  /** Human-readable description, used in the audit log. */
  readonly label: string;
  /** Equality filters combined with AND. Empty means "every device". */
  readonly filters: readonly AudienceFilter[];
}

/**
 * Translate an audience into the filters used to select device tokens.
 *
 * Only equality filters are used so every audience is answerable from a single
 * composite index and cannot silently fall back to a full-collection scan.
 */
export function resolveAudience(audience: string): AudienceQuerySpec {
  switch (audience) {
    case 'all':
      return { label: 'All users', filters: [] };

    case 'free':
      // NOTE: the mobile app has no premium feature yet, so every device
      // currently reports isPremium=false and this behaves like `all`. It
      // becomes meaningful once plan 12 (premium) ships — no function change
      // required.
      return {
        label: 'Free users',
        filters: [{ field: 'isPremium', value: false }],
      };

    case 'premium':
      return {
        label: 'Premium users',
        filters: [{ field: 'isPremium', value: true }],
      };

    case 'bangladesh':
      return {
        label: 'Users in Bangladesh',
        filters: [{ field: 'countryCode', value: 'BD' }],
      };

    default:
      throw new Error(
        `Unknown audience '${audience}'. Expected one of: ${PUSH_AUDIENCES.join(', ')}`,
      );
  }
}

/** Whether `audience` is a value this function knows how to target. */
export function isKnownAudience(audience: unknown): audience is PushAudience {
  return (
    typeof audience === 'string' &&
    (PUSH_AUDIENCES as readonly string[]).includes(audience)
  );
}

/** Normalise a stored locale value onto a supported language. */
export function normalizeLocale(value: unknown): PushLocale {
  return value === 'en' ? 'en' : DEFAULT_PUSH_LOCALE;
}

/**
 * FCM error codes that mean the token is permanently dead and should be deleted.
 *
 * Anything else (quota, unavailable, internal) is transient — deleting on those
 * would silently unsubscribe healthy devices during an outage.
 */
const PERMANENT_TOKEN_ERRORS = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

export function isPermanentTokenError(code: string | undefined): boolean {
  return code !== undefined && PERMANENT_TOKEN_ERRORS.has(code);
}
