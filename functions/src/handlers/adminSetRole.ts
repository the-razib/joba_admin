import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { requireAdmin, Role } from '../middleware/requireAdmin';
import { writeAuditLog } from '../services/audit';

export const adminSetRole = onCall(
  { region: 'asia-south1', maxInstances: 10 },
  async (request) => {
    const callerAdmin = requireAdmin(request, 'superAdmin');

    const { targetUid, role, active } = request.data ?? {};
    if (!targetUid || typeof targetUid !== 'string') {
      throw new HttpsError(
        'invalid-argument',
        'targetUid is required to update admin role.',
      );
    }

    const validRoles: Role[] = ['superAdmin', 'editor', 'viewer'];
    if (!role || !validRoles.includes(role as Role)) {
      throw new HttpsError(
        'invalid-argument',
        `Role must be one of: ${validRoles.join(', ')}.`,
      );
    }

    // 1. Last active Super Admin protection
    if (role !== 'superAdmin' || active === false) {
      const superAdminsSnap = await admin
        .firestore()
        .collection('admins')
        .where('role', '==', 'superAdmin')
        .where('active', '==', true)
        .get();

      const isTargetActiveSuperAdmin = superAdminsSnap.docs.some(
        (doc) => doc.id === targetUid,
      );

      if (isTargetActiveSuperAdmin && superAdminsSnap.size <= 1) {
        throw new HttpsError(
          'failed-precondition',
          'Cannot demote or deactivate the last active Super Admin.',
        );
      }
    }

    try {
      // 2. Set Custom Claims in Firebase Auth
      await admin.auth().setCustomUserClaims(targetUid, {
        role,
        admin: true,
      });

      // 3. Update Firestore Admin profile document
      const updateData: Record<string, any> = {
        role,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      if (typeof active === 'boolean') {
        updateData.active = active;
      }

      await admin
        .firestore()
        .collection('admins')
        .doc(targetUid)
        .set(updateData, { merge: true });

      // 4. Write audit log
      await writeAuditLog({
        adminUid: callerAdmin.uid,
        adminEmail: callerAdmin.email ?? '',
        adminRole: callerAdmin.role,
        module: 'Admin Management',
        action: 'update',
        targetId: targetUid,
        summary: `Updated role for UID ${targetUid} to ${role}`,
        details: `Role updated to ${role}${typeof active === 'boolean' ? `, active: ${active}` : ''}`,
      });

      return {
        success: true,
        targetUid,
        role,
        active,
      };
    } catch (error: any) {
      if (error instanceof HttpsError) throw error;
      throw new HttpsError(
        'internal',
        error.message || 'Failed to update admin role.',
      );
    }
  },
);
