import 'package:joba_admin/features/push_notifications/models/push_notification.dart';

/// Outcome of a real FCM dispatch, as reported by the `adminSendPush` callable.
class DispatchResult {
  const DispatchResult({
    required this.accepted,
    required this.rejected,
    this.targeted = 0,
    this.pruned = 0,
    this.messageId,
    this.audienceLabel,
    this.error,
    this.isPublish = false,
  });

  /// Result of publishing an in-app-only campaign: no devices are contacted, so
  /// zero counts here mean "not applicable", not "reached nobody".
  const DispatchResult.published()
    : accepted = 0,
      rejected = 0,
      targeted = 0,
      pruned = 0,
      messageId = null,
      audienceLabel = null,
      error = null,
      isPublish = true;

  /// Devices FCM accepted the message for.
  final int accepted;

  /// Devices FCM rejected — overwhelmingly stale tokens.
  final int rejected;

  /// Registered devices the audience matched before sending.
  final int targeted;

  /// Dead tokens deleted as a result of this dispatch.
  final int pruned;

  /// Message id of the first accepted send.
  final String? messageId;

  /// Human-readable audience description from the server-side mapping.
  final String? audienceLabel;

  /// Set when the dispatch failed outright.
  final String? error;

  /// Whether this was an in-app publish rather than a push send.
  final bool isPublish;

  bool get succeeded => error == null && !(accepted == 0 && rejected > 0);

  /// A push campaign whose audience matched nobody. Not an error, but the admin
  /// needs to know it reached zero devices rather than assume success.
  ///
  /// Never true for a publish: an in-app campaign targets no devices by design.
  bool get reachedNobody => !isPublish && targeted == 0;
}

abstract class PushRepository {
  /// Campaigns for the list view, newest first.
  Future<List<PushNotification>> fetchCampaigns({int limit = 50});

  /// Create or update a draft. Returns the campaign id, which the backend
  /// assigns for new campaigns.
  Future<String> saveDraft(PushNotification campaign);

  Future<void> deleteCampaign(String id, {String? imageUrl});

  /// Ask the backend to deliver [campaign] to real devices over FCM.
  Future<DispatchResult> dispatch(PushNotification campaign);

  /// Make an IN-APP campaign visible to the mobile app.
  ///
  /// In-app campaigns are not pushed anywhere: the app reads published
  /// documents and renders them itself. Publishing therefore only means moving
  /// the campaign to `sent` so it passes the app's query — there is no FCM call
  /// and no per-device result to report.
  Future<void> publishInApp(PushNotification campaign);
}

/// In-memory implementation for running the panel without Firebase
/// (`--dart-define=USE_MOCKS=true`) and for widget tests.
///
/// The dispatch counts here are fabricated on purpose and only ever appear in
/// mock mode; the real repository reports what FCM actually accepted.
class MockPushRepository implements PushRepository {
  MockPushRepository() {
    _campaigns.addAll(_seedCampaigns());
  }

  final List<PushNotification> _campaigns = <PushNotification>[];
  int _idCounter = 100;

  @override
  Future<List<PushNotification>> fetchCampaigns({int limit = 50}) async {
    return _campaigns.take(limit).toList();
  }

  @override
  Future<String> saveDraft(PushNotification campaign) async {
    final index = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (index >= 0) {
      _campaigns[index] = campaign;
      return campaign.id;
    }

    final id = campaign.id.isEmpty ? 'PN-${_idCounter++}' : campaign.id;
    _campaigns.insert(
      0,
      PushNotification.fromMap({
        ...campaign.toMap(),
        'id': id,
      }, docId: id),
    );
    return id;
  }

  @override
  Future<void> deleteCampaign(String id, {String? imageUrl}) async {
    _campaigns.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> publishInApp(PushNotification campaign) async {
    final id = await saveDraft(campaign);
    final index = _campaigns.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _campaigns[index] = _campaigns[index].copyWith(
        status: PushStatus.sent,
        sentAt: DateTime.now(),
      );
    }
  }

  @override
  Future<DispatchResult> dispatch(PushNotification campaign) async {
    final id = await saveDraft(campaign);
    final targeted = switch (campaign.audience) {
      PushAudience.all => 2100,
      PushAudience.free => 1500,
      PushAudience.premium => 42,
      PushAudience.bangladesh => 1800,
    };
    final rejected = (targeted * 0.02).round();

    final index = _campaigns.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _campaigns[index] = _campaigns[index].copyWith(
        status: PushStatus.sent,
        sentAt: DateTime.now(),
        sentCount: targeted - rejected,
        failedCount: rejected,
        messageId: 'mock/$id',
      );
    }

    return DispatchResult(
      accepted: targeted - rejected,
      rejected: rejected,
      targeted: targeted,
      messageId: 'mock/$id',
      audienceLabel: campaign.audience.name,
    );
  }

  List<PushNotification> _seedCampaigns() {
    final now = DateTime.now();
    return [
      PushNotification(
        id: 'PN-005',
        titleBn: 'নতুন অ্যাভাটার এসেছে',
        titleEn: 'New avatars are live',
        bodyBn: 'আপনার প্রোফাইলের জন্য নতুন ছবি বেছে নিন।',
        bodyEn: 'Pick a new picture for your profile.',
        audience: PushAudience.all,
        channel: NotificationChannel.both,
        inAppLayout: InAppLayout.modal,
        imageUrl: 'https://storage.googleapis.com/joba-demo/avatar-launch.png',
        actionLabelBn: 'দেখুন',
        actionLabelEn: 'Try it',
        actionUrl: 'joba://profile',
        status: PushStatus.sent,
        sentAt: now.subtract(const Duration(hours: 5)),
        createdAt: now.subtract(const Duration(hours: 6)),
        sentCount: 19800,
        failedCount: 400,
        messageId: 'mock/PN-005',
      ),
      PushNotification(
        id: 'PN-004',
        titleBn: 'আপনার পিরিয়ড আসছে',
        titleEn: 'Your period is approaching',
        bodyBn: 'প্রস্তুতি নিয়ে রাখুন।',
        bodyEn: 'A good time to get ready.',
        audience: PushAudience.all,
        status: PushStatus.sent,
        sentAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
        sentCount: 21400,
        failedCount: 430,
        messageId: 'mock/PN-004',
      ),
      PushNotification(
        id: 'PN-003',
        titleBn: 'নিয়মিত ট্র্যাক করুন',
        titleEn: 'Track regularly',
        bodyBn: 'নিয়মিত লগ করলে পূর্বাভাস আরও নিখুঁত হয়।',
        bodyEn: 'Logging regularly makes predictions more accurate.',
        audience: PushAudience.free,
        channel: NotificationChannel.push,
        status: PushStatus.sent,
        sentAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 3)),
        sentCount: 15200,
        failedCount: 300,
        messageId: 'mock/PN-003',
      ),
      PushNotification(
        id: 'PN-002',
        titleBn: 'প্রিমিয়াম অফার',
        titleEn: 'Premium offer inside',
        bodyBn: 'সীমিত সময়ের জন্য ছাড়।',
        bodyEn: 'Limited-time discount.',
        audience: PushAudience.free,
        channel: NotificationChannel.inApp,
        inAppLayout: InAppLayout.card,
        imageUrl: 'https://storage.googleapis.com/joba-demo/premium-offer.png',
        actionLabelBn: 'আপগ্রেড',
        actionLabelEn: 'Upgrade',
        actionUrl: 'joba://premium',
        status: PushStatus.sent,
        sentAt: now.subtract(const Duration(days: 6)),
        createdAt: now.subtract(const Duration(days: 6)),
        sentCount: 14900,
        failedCount: 290,
        messageId: 'mock/PN-002',
      ),
      PushNotification(
        id: 'PN-001',
        titleBn: 'স্বাস্থ্য টিপস',
        titleEn: 'Health tips',
        bodyBn: 'এই সপ্তাহের পরামর্শ দেখুন।',
        bodyEn: 'See this week\'s advice.',
        audience: PushAudience.bangladesh,
        channel: NotificationChannel.push,
        status: PushStatus.draft,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
