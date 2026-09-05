import { onCall } from 'firebase-functions/v2/https';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

export const sathiRecordFaqMatch = onCall(
  {
    region: 'asia-south1',
    maxInstances: 10,
    memory: '128MiB',
  },
  async () => {
    const db = getFirestore();
    const todayKey = new Date().toISOString().split('T')[0];

    const dailyRef = db.collection('sathi_ai_usage_daily').doc(todayKey);
    await dailyRef.set(
      {
        date: todayKey,
        faqMatches: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return { success: true };
  }
);
