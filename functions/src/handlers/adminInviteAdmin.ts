import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { requireAdmin } from '../middleware/requireAdmin';
import { writeAuditLog } from '../services/audit';

export const adminInviteAdmin = onCall(
  { region: 'asia-south1', maxInstances: 10 },
  async (request) => {
    const admin = requireAdmin(request, 'superAdmin');

    const { email, role, name } = request.data ?? {};
    if (!email || !role) {
      throw new HttpsError(
        'invalid-argument',
        'Email and role are required to invite an admin.',
      );
    }

    await writeAuditLog({
      adminUid: admin.uid,
      adminEmail: admin.email ?? '',
      adminRole: admin.role,
      module: 'Admin Management',
      action: 'create',
      summary: `Invited new admin ${email} with role ${role}`,
      details: `Name: ${name ?? ''}, Email: ${email}, Role: ${role}`,
    });

    // Skeleton implementation — full invite / user creation flow lands in Plan 14
    return {
      success: true,
      email,
      role,
      status: 'invited_skeleton',
    };
  },
);
