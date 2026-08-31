import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { requireAdmin, Role } from '../middleware/requireAdmin';
import { writeAuditLog } from '../services/audit';

function generateTempPassword(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%&*';
  let pass = 'Joba#';
  for (let i = 0; i < 8; i++) {
    pass += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return pass;
}

export const adminInviteAdmin = onCall(
  { region: 'asia-south1', maxInstances: 10 },
  async (request) => {
    const callerAdmin = requireAdmin(request, 'superAdmin');

    const { email, role, name, tempPassword: customPassword } = request.data ?? {};
    if (!email || typeof email !== 'string' || !email.includes('@')) {
      throw new HttpsError(
        'invalid-argument',
        'A valid email address is required to invite an admin.',
      );
    }

    const validRoles: Role[] = ['superAdmin', 'editor', 'viewer'];
    if (!role || !validRoles.includes(role as Role)) {
      throw new HttpsError(
        'invalid-argument',
        `Role must be one of: ${validRoles.join(', ')}.`,
      );
    }

    const adminName = (name && typeof name === 'string' && name.trim().length > 0)
      ? name.trim()
      : email.split('@')[0];

    const normalizedEmail = email.trim().toLowerCase();

    // 1. Check if user already exists
    try {
      const existingUser = await admin.auth().getUserByEmail(normalizedEmail);
      if (existingUser) {
        throw new HttpsError(
          'already-exists',
          `An account with email '${normalizedEmail}' already exists.`,
        );
      }
    } catch (e: any) {
      if (e instanceof HttpsError) throw e;
      if (e.code !== 'auth/user-not-found') {
        throw new HttpsError(
          'internal',
          e.message || 'Error checking user existence.',
        );
      }
    }

    const tempPassword = (customPassword && typeof customPassword === 'string' && customPassword.length >= 8)
      ? customPassword
      : generateTempPassword();

    try {
      // 2. Create Firebase Auth user
      const userRecord = await admin.auth().createUser({
        email: normalizedEmail,
        password: tempPassword,
        displayName: adminName,
        emailVerified: true,
      });

      // 3. Set Custom Claims
      await admin.auth().setCustomUserClaims(userRecord.uid, {
        role,
        admin: true,
      });

      // 4. Create Firestore Admin profile document
      await admin.firestore().collection('admins').doc(userRecord.uid).set({
        uid: userRecord.uid,
        name: adminName,
        email: normalizedEmail,
        role,
        active: true,
        mustChangePassword: true,
        invitedBy: callerAdmin.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastActive: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 5. Write audit log
      await writeAuditLog({
        adminUid: callerAdmin.uid,
        adminEmail: callerAdmin.email ?? '',
        adminRole: callerAdmin.role,
        module: 'Admin Management',
        action: 'create',
        targetId: userRecord.uid,
        summary: `Invited new admin ${normalizedEmail} as ${role}`,
        details: `Created admin account for ${adminName} (${normalizedEmail}) with role ${role}`,
      });

      return {
        success: true,
        uid: userRecord.uid,
        email: normalizedEmail,
        role,
        tempPassword,
      };
    } catch (error: any) {
      if (error instanceof HttpsError) throw error;
      throw new HttpsError(
        'internal',
        error.message || 'Failed to create admin user.',
      );
    }
  },
);
