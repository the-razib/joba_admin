import { onCall } from 'firebase-functions/v2/https';
import { requireAdmin } from '../middleware/requireAdmin';
import { writeAuditLog } from '../services/audit';

export const adminGetProjectUsage = onCall(
  { region: 'asia-south1', maxInstances: 10 },
  async (request) => {
    const admin = requireAdmin(request, 'superAdmin');

    const { days = 90 } = request.data ?? {};

    await writeAuditLog({
      adminUid: admin.uid,
      adminEmail: admin.email ?? '',
      adminRole: admin.role,
      module: 'Usage & Cost',
      action: 'view',
      summary: `Viewed Cloud Monitoring usage analytics for past ${days} days`,
    });

    // Skeleton implementation — full Cloud Monitoring query + cache lands in Plan 17
    return {
      success: true,
      days,
      status: 'usage_skeleton',
      data: [],
    };
  },
);
