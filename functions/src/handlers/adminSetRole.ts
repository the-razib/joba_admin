import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { requireAdmin } from '../middleware/requireAdmin';
import { writeAuditLog } from '../services/audit';

export const adminSetRole = onCall(
  { region: 'asia-south1', maxInstances: 10 },
  async (request) => {
    const admin = requireAdmin(request, 'superAdmin');

    const { targetUid, role, active } = request.data ?? {};
    if (!targetUid || !role) {
      throw new HttpsError(
        'invalid-argument',
        'targetUid and role are required to update admin role.',
      );
    }

    await writeAuditLog({
      adminUid: admin.uid,
      adminEmail: admin.email ?? '',
      adminRole: admin.role,
      module: 'Admin Management',
      action: 'update',
      targetId: targetUid,
      summary: `Updated role for UID ${targetUid} to ${role}`,
      details: `Active status: ${active ?? true}`,
    });

    // Skeleton implementation — full claim update + doc sync lands in Plan 14
    return {
      success: true,
      targetUid,
      role,
      status: 'role_updated_skeleton',
    };
  },
);
