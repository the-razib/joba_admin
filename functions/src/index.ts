import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export Callable Cloud Functions
export { adminSendPush } from './handlers/adminSendPush';
export { adminInviteAdmin } from './handlers/adminInviteAdmin';
export { adminSetRole } from './handlers/adminSetRole';
export { adminGetProjectUsage } from './handlers/adminGetProjectUsage';
export { collectUsageDaily } from './handlers/collectUsageDaily';
export { adminSetStorageCors } from './handlers/adminSetStorageCors';
