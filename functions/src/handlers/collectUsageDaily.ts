import { onSchedule } from 'firebase-functions/v2/scheduler';
import { CloudMonitoringService } from '../services/cloudMonitoring';

/**
 * Scheduled Cloud Function that runs daily at 03:00 AM (Asia/Dhaka)
 * to pull finalized yesterday metrics from Google Cloud Monitoring API
 * and write the daily cached rollup into Firestore collection `usage_daily/{yyyy-mm-dd}`.
 */
export const collectUsageDaily = onSchedule(
  {
    schedule: '0 3 * * *',
    timeZone: 'Asia/Dhaka',
    region: 'asia-south1',
    maxInstances: 1,
  },
  async () => {
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
    console.log(`[collectUsageDaily] Running daily Cloud Monitoring rollup for ${yesterday.toISOString().split('T')[0]}...`);
    const rollup = await CloudMonitoringService.syncDay(yesterday);
    console.log(`[collectUsageDaily] Successfully finalized usage rollup:`, rollup);
  }
);
