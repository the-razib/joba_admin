import { onCall } from 'firebase-functions/v2/https';
import { requireAdmin } from '../middleware/requireAdmin';
import { writeAuditLog } from '../services/audit';

export const adminSendPush = onCall(
  { region: 'asia-south1', maxInstances: 10 },
  async (request) => {
    const admin = requireAdmin(request, 'editor');

    const { campaignId, audience, title, body } = request.data ?? {};

    await writeAuditLog({
      adminUid: admin.uid,
      adminEmail: admin.email ?? '',
      adminRole: admin.role,
      module: 'Push Notifications',
      action: 'send',
      targetId: campaignId,
      summary: `Dispatched push campaign: ${title ?? campaignId ?? 'Untitled'}`,
      details: `Audience: ${audience ?? 'all'}, Body: ${body ?? ''}`,
    });

    // Skeleton implementation — full FCM HTTP v1 dispatch lands in Plan 11
    return {
      success: true,
      accepted: 1,
      rejected: 0,
      messageId: `mock_${Date.now()}`,
      status: 'dispatched_skeleton',
    };
  },
);
