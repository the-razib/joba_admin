import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { requireAdmin } from '../middleware/requireAdmin';
import { writeAuditLog } from '../services/audit';
import {
  FCM_TOKENS_COLLECTION,
  PUSH_CAMPAIGNS_COLLECTION,
  isKnownAudience,
  isPermanentTokenError,
  normalizeLocale,
  resolveAudience,
  type PushLocale,
} from '../services/pushAudience';

/** FCM accepts at most 500 tokens per multicast call. */
const MULTICAST_BATCH_SIZE = 500;

/** Token documents read per Firestore page. */
const TOKEN_PAGE_SIZE = 500;

/**
 * Hard ceiling on devices targeted by one campaign.
 *
 * Protects against an unbounded run (function timeout, runaway cost) if the
 * token collection grows far beyond expectations. Exceeding it is reported to
 * the admin rather than silently truncated.
 */
const MAX_TARGET_DEVICES = 200_000;

interface DeviceToken {
  docId: string;
  token: string;
  locale: PushLocale;
}

interface LocalizedCopy {
  title: string;
  body: string;
}

/**
 * Send a push campaign to real devices.
 *
 * Contract with the panel: the campaign document already exists and is a draft
 * (or a previously sent campaign being resent). This function owns the entire
 * status lifecycle — `sending` while it works, then `sent` or `failed` — so the
 * panel never has to guess.
 */
export const adminSendPush = onCall(
  {
    region: 'asia-south1',
    maxInstances: 10,
    // A large audience means many Firestore pages plus many multicast calls.
    timeoutSeconds: 540,
    memory: '512MiB',
  },
  async (request) => {
    const adminCtx = requireAdmin(request, 'editor');

    const campaignId = String(request.data?.campaignId ?? '').trim();
    if (!campaignId) {
      throw new HttpsError('invalid-argument', 'campaignId is required');
    }

    const db = admin.firestore();
    const campaignRef = db
      .collection(PUSH_CAMPAIGNS_COLLECTION)
      .doc(campaignId);
    const snapshot = await campaignRef.get();

    if (!snapshot.exists) {
      throw new HttpsError('not-found', `Campaign ${campaignId} not found`);
    }

    const campaign = snapshot.data() ?? {};
    const channel = String(campaign.channel ?? 'push');

    // In-app-only campaigns are delivered by the mobile app reading the
    // document. There is nothing to push.
    if (channel === 'inApp') {
      throw new HttpsError(
        'failed-precondition',
        'This campaign is in-app only. Publish it instead of sending a push.',
      );
    }

    // Guard against two admins dispatching the same campaign at once.
    if (campaign.status === 'sending') {
      throw new HttpsError(
        'failed-precondition',
        'This campaign is already being sent.',
      );
    }

    const audience = campaign.audience ?? 'all';
    if (!isKnownAudience(audience)) {
      throw new HttpsError(
        'invalid-argument',
        `Campaign has an unsupported audience '${audience}'.`,
      );
    }
    const audienceSpec = resolveAudience(audience);

    const copy = extractCopy(campaign);
    if (!copy.bn.title || !copy.bn.body) {
      throw new HttpsError(
        'invalid-argument',
        'Campaign is missing Bengali title or body.',
      );
    }

    await campaignRef.update({
      status: 'sending',
      errorMessage: admin.firestore.FieldValue.delete(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    try {
      const tokens = await loadAudienceTokens(db, audienceSpec.filters);

      if (tokens.length === 0) {
        // Not an error: a valid audience can legitimately be empty. Recording
        // it as a completed send with zero recipients is the honest outcome and
        // tells the admin the audience matched nobody.
        await campaignRef.update({
          status: 'sent',
          sentCount: 0,
          failedCount: 0,
          messageId: null,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        await writeAuditLog({
          adminUid: adminCtx.uid,
          adminEmail: adminCtx.email ?? '',
          adminRole: adminCtx.role,
          module: 'Push Notifications',
          action: 'updated',
          targetId: campaignId,
          summary: `Push campaign reached no devices: ${copy.en.title || copy.bn.title}`,
          details: `Audience "${audienceSpec.label}" matched 0 registered devices.`,
          meta: { audience, sent: 0, failed: 0 },
        });

        return {
          success: true,
          sent: 0,
          failed: 0,
          messageId: null,
          audience,
          audienceLabel: audienceSpec.label,
          targeted: 0,
        };
      }

      const result = await sendToTokens(db, tokens, copy, {
        campaignId,
        actionType: String(campaign.actionType ?? 'none'),
        actionValue: String(campaign.actionUrl ?? ''),
        imageUrl:
          typeof campaign.imageUrl === 'string' && campaign.imageUrl.length > 0
            ? campaign.imageUrl
            : undefined,
      });

      // Every single delivery failing means something systemic (bad
      // credentials, all tokens stale) — surface it instead of reporting a
      // successful send of nothing.
      const allFailed = result.sent === 0 && result.failed > 0;

      await campaignRef.update({
        status: allFailed ? 'failed' : 'sent',
        sentCount: result.sent,
        failedCount: result.failed,
        messageId: result.firstMessageId ?? null,
        ...(allFailed
          ? { errorMessage: result.firstError ?? 'All deliveries failed' }
          : {}),
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await writeAuditLog({
        adminUid: adminCtx.uid,
        adminEmail: adminCtx.email ?? '',
        adminRole: adminCtx.role,
        module: 'Push Notifications',
        action: allFailed ? 'failedLogin' : 'updated',
        targetId: campaignId,
        status: allFailed ? 'failed' : 'success',
        summary: `Sent push campaign: ${copy.en.title || copy.bn.title}`,
        details:
          `Audience "${audienceSpec.label}" — targeted ${tokens.length}, ` +
          `delivered ${result.sent}, failed ${result.failed}, ` +
          `pruned ${result.pruned} dead tokens.`,
        meta: {
          audience,
          targeted: tokens.length,
          sent: result.sent,
          failed: result.failed,
          pruned: result.pruned,
        },
      });

      return {
        success: !allFailed,
        sent: result.sent,
        failed: result.failed,
        pruned: result.pruned,
        messageId: result.firstMessageId ?? null,
        audience,
        audienceLabel: audienceSpec.label,
        targeted: tokens.length,
        ...(allFailed ? { error: result.firstError } : {}),
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);

      // Never leave a campaign stuck in `sending`: the panel would show a
      // spinner forever and the campaign could not be retried.
      await campaignRef.update({
        status: 'failed',
        errorMessage: message,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await writeAuditLog({
        adminUid: adminCtx.uid,
        adminEmail: adminCtx.email ?? '',
        adminRole: adminCtx.role,
        module: 'Push Notifications',
        action: 'failedLogin',
        targetId: campaignId,
        status: 'failed',
        summary: `Push campaign failed: ${campaignId}`,
        details: message,
        meta: { audience },
      });

      if (error instanceof HttpsError) throw error;
      throw new HttpsError('internal', `Push dispatch failed: ${message}`);
    }
  },
);

/** Pull the bilingual copy out of a campaign document, tolerating both the
 * nested (`title.bn`) and flat (`titleBn`) shapes the panel writes. */
function extractCopy(campaign: admin.firestore.DocumentData): {
  bn: LocalizedCopy;
  en: LocalizedCopy;
} {
  const title = (campaign.title ?? {}) as Record<string, unknown>;
  const body = (campaign.body ?? {}) as Record<string, unknown>;

  const bnTitle = String(title.bn ?? campaign.titleBn ?? '').trim();
  const bnBody = String(body.bn ?? campaign.bodyBn ?? '').trim();
  const enTitle = String(title.en ?? campaign.titleEn ?? '').trim();
  const enBody = String(body.en ?? campaign.bodyEn ?? '').trim();

  return {
    bn: { title: bnTitle, body: bnBody },
    // Fall back to Bengali so an English-locale device still gets a readable
    // notification rather than an empty one.
    en: { title: enTitle || bnTitle, body: enBody || bnBody },
  };
}

/** Page through the token collection collecting the targeted devices. */
async function loadAudienceTokens(
  db: admin.firestore.Firestore,
  filters: readonly { field: string; value: string | boolean }[],
): Promise<DeviceToken[]> {
  let query: admin.firestore.Query = db.collection(FCM_TOKENS_COLLECTION);
  for (const filter of filters) {
    query = query.where(filter.field, '==', filter.value);
  }
  // Ordering by document id keeps paging stable and needs no extra index.
  query = query.orderBy(admin.firestore.FieldPath.documentId());

  const tokens: DeviceToken[] = [];
  let cursor: admin.firestore.QueryDocumentSnapshot | undefined;

  for (;;) {
    let page = query.limit(TOKEN_PAGE_SIZE);
    if (cursor) page = page.startAfter(cursor);

    const snapshot = await page.get();
    if (snapshot.empty) break;

    for (const doc of snapshot.docs) {
      const token = doc.get('token');
      if (typeof token !== 'string' || token.length === 0) continue;
      tokens.push({
        docId: doc.id,
        token,
        locale: normalizeLocale(doc.get('locale')),
      });
    }

    if (tokens.length >= MAX_TARGET_DEVICES) {
      throw new HttpsError(
        'resource-exhausted',
        `Audience exceeds the ${MAX_TARGET_DEVICES} device safety limit. ` +
          'Narrow the audience or raise MAX_TARGET_DEVICES deliberately.',
      );
    }

    if (snapshot.size < TOKEN_PAGE_SIZE) break;
    cursor = snapshot.docs[snapshot.docs.length - 1];
  }

  return tokens;
}

interface SendOutcome {
  sent: number;
  failed: number;
  pruned: number;
  firstMessageId?: string;
  firstError?: string;
}

/**
 * Deliver to every token, grouped by locale so each device gets its own
 * language, and batched to FCM's 500-token multicast limit.
 */
async function sendToTokens(
  db: admin.firestore.Firestore,
  tokens: DeviceToken[],
  copy: { bn: LocalizedCopy; en: LocalizedCopy },
  payload: {
    campaignId: string;
    actionType: string;
    actionValue: string;
    imageUrl?: string;
  },
): Promise<SendOutcome> {
  const messaging = admin.messaging();
  const outcome: SendOutcome = { sent: 0, failed: 0, pruned: 0 };
  const deadDocIds: string[] = [];

  const byLocale = new Map<PushLocale, DeviceToken[]>();
  for (const device of tokens) {
    const bucket = byLocale.get(device.locale) ?? [];
    bucket.push(device);
    byLocale.set(device.locale, bucket);
  }

  for (const [locale, devices] of byLocale) {
    const localized = locale === 'en' ? copy.en : copy.bn;

    for (let i = 0; i < devices.length; i += MULTICAST_BATCH_SIZE) {
      const batch = devices.slice(i, i + MULTICAST_BATCH_SIZE);

      const response = await messaging.sendEachForMulticast({
        tokens: batch.map((d) => d.token),
        notification: {
          title: localized.title,
          body: localized.body,
          ...(payload.imageUrl ? { imageUrl: payload.imageUrl } : {}),
        },
        // The mobile handler routes on these. Values must be strings: FCM
        // rejects a data payload containing anything else.
        //
        // `imageUrl` is duplicated here on purpose. When the app is in the
        // FOREGROUND, Android does not draw the notification and the app
        // re-renders it locally — so the client needs the image URL from a
        // field it can always read, independent of how the SDK happens to map
        // the notification block.
        data: {
          type: 'campaign',
          campaignId: payload.campaignId,
          actionType: payload.actionType,
          actionValue: payload.actionValue,
          imageUrl: payload.imageUrl ?? '',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'app_updates',
            ...(payload.imageUrl ? { imageUrl: payload.imageUrl } : {}),
          },
        },
      });

      outcome.sent += response.successCount;
      outcome.failed += response.failureCount;

      response.responses.forEach((individual, index) => {
        if (individual.success) {
          if (!outcome.firstMessageId && individual.messageId) {
            outcome.firstMessageId = individual.messageId;
          }
          return;
        }

        const code = individual.error?.code;
        if (!outcome.firstError) {
          outcome.firstError = individual.error?.message ?? code ?? 'unknown';
        }
        if (isPermanentTokenError(code)) {
          deadDocIds.push(batch[index].docId);
        }
      });
    }
  }

  outcome.pruned = await pruneDeadTokens(db, deadDocIds);
  return outcome;
}

/**
 * Delete tokens FCM rejected as permanently invalid.
 *
 * Without this, uninstalled devices accumulate forever: every future campaign
 * pays to read them, tries to deliver to them, and reports an ever-growing
 * failure count that looks like a bug.
 */
async function pruneDeadTokens(
  db: admin.firestore.Firestore,
  docIds: string[],
): Promise<number> {
  if (docIds.length === 0) return 0;

  const WRITE_BATCH_LIMIT = 450;
  let pruned = 0;

  for (let i = 0; i < docIds.length; i += WRITE_BATCH_LIMIT) {
    const slice = docIds.slice(i, i + WRITE_BATCH_LIMIT);
    const batch = db.batch();
    for (const id of slice) {
      batch.delete(db.collection(FCM_TOKENS_COLLECTION).doc(id));
    }
    try {
      await batch.commit();
      pruned += slice.length;
    } catch {
      // Pruning is housekeeping — a failure here must not fail the campaign
      // that was otherwise delivered successfully.
    }
  }

  return pruned;
}
