import { CallableRequest, HttpsError } from 'firebase-functions/v2/https';

export type Role = 'viewer' | 'editor' | 'superAdmin';

export const ROLE_RANK: Record<Role, number> = {
  viewer: 0,
  editor: 1,
  superAdmin: 2,
};

export interface AdminContext {
  uid: string;
  role: Role;
  email?: string;
}

export function requireAdmin(
  req: CallableRequest,
  minRole: Role,
): AdminContext {
  const auth = req.auth;
  if (!auth || !auth.uid) {
    throw new HttpsError('unauthenticated', 'Sign in required');
  }

  const role = (auth.token?.role as Role) ?? null;
  if (
    !role ||
    ROLE_RANK[role] === undefined ||
    ROLE_RANK[role] < ROLE_RANK[minRole]
  ) {
    throw new HttpsError(
      'permission-denied',
      `Insufficient role. Minimum required role is '${minRole}'.`,
    );
  }

  return {
    uid: auth.uid,
    role,
    email: auth.token?.email,
  };
}
