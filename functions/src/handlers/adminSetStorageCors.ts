import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { requireAdmin } from '../middleware/requireAdmin';

export const adminSetStorageCors = onCall(
  { region: 'asia-south1', maxInstances: 5 },
  async (request) => {
    requireAdmin(request, 'superAdmin');

    const bucket = admin.storage().bucket('joba-a913b.firebasestorage.app');
    await bucket.setCorsConfiguration([
      {
        maxAgeSeconds: 3600,
        method: ['GET', 'HEAD', 'PUT', 'POST', 'DELETE', 'OPTIONS'],
        origin: ['*'],
        responseHeader: ['*'],
      },
    ]);

    return {
      success: true,
      message:
        'CORS successfully enabled for all origins on joba-a913b.firebasestorage.app',
    };
  },
);
