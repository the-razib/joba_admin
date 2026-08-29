import * as admin from 'firebase-admin';

export interface AuditLogEntry {
  adminUid: string;
  adminName?: string;
  adminEmail: string;
  adminRole?: string;
  module: string;
  action: string;
  targetId?: string;
  summary: string;
  details?: string;
  ip?: string;
  location?: string;
  status?: 'success' | 'failed';
  meta?: Record<string, unknown>;
}

export async function writeAuditLog(entry: AuditLogEntry): Promise<string> {
  const db = admin.firestore();
  const docRef = await db.collection('audit_logs').add({
    adminUid: entry.adminUid,
    adminName: entry.adminName ?? entry.adminEmail,
    adminEmail: entry.adminEmail,
    adminRole: entry.adminRole ?? 'superAdmin',
    action: entry.action,
    module: entry.module,
    details: entry.details ?? entry.summary,
    summary: entry.summary,
    targetId: entry.targetId ?? null,
    ip: entry.ip ?? 'CloudFunction',
    location: entry.location ?? 'Server',
    status: entry.status ?? 'success',
    meta: entry.meta ?? {},
    time: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return docRef.id;
}
