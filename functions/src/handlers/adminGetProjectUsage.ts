import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { requireAdmin } from '../middleware/requireAdmin';
import { writeAuditLog } from '../services/audit';
import { CloudMonitoringService } from '../services/cloudMonitoring';

export const adminGetProjectUsage = onCall(
  { region: 'asia-south1', maxInstances: 10 },
  async (request) => {
    const admin = requireAdmin(request, 'viewer');
    const { days = 90, backfillDays = 0 } = request.data ?? {};

    const db = getFirestore();
    const today = new Date();

    try {
      // 1. Sync today's live metrics from Cloud Monitoring API into Firestore
      await CloudMonitoringService.syncDay(today);

      // 1b. If backfill requested, sync historical range
      if (typeof backfillDays === 'number' && backfillDays > 0) {
        await CloudMonitoringService.backfillRange(Math.min(backfillDays, 90));
      }

      // 2. Fetch past 'days' documents from usage_daily collection
      const snap = await db
        .collection('usage_daily')
        .orderBy('date', 'desc')
        .limit(days)
        .get();

      const records = snap.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        date: doc.data().date?.toDate ? doc.data().date.toDate().toISOString() : doc.data().date,
      }));

      await writeAuditLog({
        adminUid: admin.uid,
        adminEmail: admin.email ?? '',
        adminRole: admin.role,
        module: 'Usage & Cost',
        action: 'view',
        summary: `Queried Cloud Monitoring API telemetry for past ${days} days`,
      });

      return {
        success: true,
        days,
        source: 'monitoring.googleapis.com',
        data: records.reverse(),
      };
    } catch (err: any) {
      console.error('Error fetching usage data in Cloud Function:', err);
      throw new HttpsError('internal', err.message || 'Failed to aggregate project usage');
    }
  },
);
