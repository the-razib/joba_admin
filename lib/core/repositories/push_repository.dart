import 'package:joba_admin/features/push_notifications/models/push_notification.dart';

/// Result of handing a campaign to the delivery layer.
///
/// FCM accepts a send and reports per-token failures asynchronously, so
/// "accepted" is not "delivered". Phase 3 fills [delivered] from the BigQuery
/// export or an Analytics rollup, not from the send call's response.
class DispatchResult {
  const DispatchResult({
    required this.accepted,
    required this.rejected,
    this.messageId,
  });

  final int accepted;
  final int rejected;
  final String? messageId;
}

/// Phase 1: mock. Phase 3: `FirebasePushRepository`.
///
/// ## Why sending cannot happen in this app
///
/// FCM HTTP v1 authenticates with a service account bearer token. Flutter Web
/// serves its bundle to the browser, so an embedded key would let any visitor
/// send notifications to every user. The legacy `Authorization: key=...`
/// server key had the same problem and was decommissioned in 2024. Sends must
/// go through an authenticated callable Cloud Function that checks the
/// caller's admin claim first.
///
/// ## The two channels take different paths
///
/// - **Push** → the callable builds an FCM HTTP v1 message. [PushAudience]
///   becomes a topic (`/topics/all`) or a condition for combinations.
///   [PushNotification.imageUrl] becomes `message.notification.image`.
/// - **In-app** → the callable writes a campaign document to Firestore. It
///   cannot use Firebase In-App Messaging: FIAM has no campaign-creation API,
///   console only. The client watches that collection and renders the dialog
///   using [PushNotification.inAppLayout].
abstract class PushRepository {
  Future<List<PushNotification>> seed();
  Future<List<PushNotification>> fetchCampaigns({int limit = 50});
  Future<void> saveDraft(PushNotification campaign);
  Future<void> deleteCampaign(String id);

  /// Phase 3 posts to the callable and returns its report.
  Future<DispatchResult> dispatch(PushNotification campaign);
}

class MockPushRepository implements PushRepository {
  @override
  Future<List<PushNotification>> seed() async {
    final now = DateTime.now();
    return [
      PushNotification(
        id: 'PN-005',
        titleBn: 'নতুন ফিচার: অ্যাভাটার কাস্টমাইজেশন',
        titleEn: 'New: customise your avatar',
        bodyBn: 'আপনার প্রোফাইলের জন্য নতুন অ্যাভাটার বেছে নিন।',
        bodyEn: 'Pick a new avatar for your profile.',
        audience: PushAudience.all,
        channel: NotificationChannel.both,
        inAppLayout: InAppLayout.modal,
        imageUrl: 'https://storage.googleapis.com/joba-demo/avatar-launch.png',
        actionLabelBn: 'দেখুন',
        actionLabelEn: 'Try it',
        actionUrl: 'joba://avatars',
        status: PushStatus.sent,
        sentAt: now.subtract(const Duration(hours: 5)),
        delivered: 19800,
        opened: 11100,
      ),
      PushNotification(
        id: 'PN-004',
        titleBn: 'আপনার পিরিয়ডের সময় কাছাকাছি',
        titleEn: 'Your period is approaching',
        bodyBn:
            'আপনার পিরিয়ডের পূর্বাভাস আগামী ৩ দিনের মধ্যে। প্রস্তুত থাকুন।',
        bodyEn: 'Your period is predicted within the next 3 days.',
        audience: PushAudience.all,
        status: PushStatus.sent,
        sentAt: now.subtract(const Duration(days: 1)),
        delivered: 21400,
        opened: 12840,
      ),
      PushNotification(
        id: 'PN-003',
        titleBn: 'নতুন আর্টিকেল: পিরিয়ড ব্যথা ব্যবস্থাপনা',
        titleEn: 'New article: Period pain management',
        bodyBn: 'প্রাকৃতিক উপায়ে ব্যথা কমানোর কার্যকরী টিপস পড়ুন।',
        bodyEn: 'Read effective natural tips to reduce period pain.',
        audience: PushAudience.free,
        status: PushStatus.sent,
        sentAt: now.subtract(const Duration(days: 3)),
        delivered: 15200,
        opened: 6900,
      ),
      PushNotification(
        id: 'PN-002',
        titleBn: 'প্রিমিয়াম অফার',
        titleEn: 'Premium offer inside',
        bodyBn: 'এই সপ্তাহে প্রিমিয়ামে ২০% ছাড়!',
        bodyEn: '20% off Premium this week!',
        audience: PushAudience.free,
        channel: NotificationChannel.inApp,
        inAppLayout: InAppLayout.card,
        imageUrl: 'https://storage.googleapis.com/joba-demo/premium-offer.png',
        actionLabelBn: 'আপগ্রেড',
        actionLabelEn: 'Upgrade',
        actionUrl: 'joba://premium',
        status: PushStatus.sent,
        sentAt: now.subtract(const Duration(days: 6)),
        delivered: 14900,
        opened: 5100,
      ),
      const PushNotification(
        id: 'PN-001',
        titleBn: 'ঔষধের রিমাইন্ডার সেট করুন',
        titleEn: 'Set your medicine reminders',
        bodyBn: 'প্রতিদিনের ঔষধের রিমাইন্ডার চালু করুন।',
        bodyEn: 'Turn on daily medicine reminders.',
        audience: PushAudience.bangladesh,
      ),
    ];
  }

  @override
  Future<DispatchResult> dispatch(PushNotification campaign) async {
    // Deterministic so the mock never invents a different number per render.
    final base = switch (campaign.audience) {
      PushAudience.all => 21000,
      PushAudience.free => 15000,
      PushAudience.premium => 4200,
      PushAudience.bangladesh => 18000,
    };
    return DispatchResult(
      accepted: base,
      rejected: (base * 0.02).round(),
      messageId: 'mock/${campaign.id}',
    );
  }

  @override
  Future<List<PushNotification>> fetchCampaigns({int limit = 50}) async => seed();

  @override
  Future<void> saveDraft(PushNotification campaign) async {}

  @override
  Future<void> deleteCampaign(String id) async {}
}
