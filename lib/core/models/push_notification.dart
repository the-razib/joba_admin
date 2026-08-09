/// Notification campaign model shared by the push composer and the in-app
/// dialog composer.
///
/// ## Where each channel actually goes in Phase 3
///
/// **Push** maps onto FCM HTTP v1
/// (`POST https://fcm.googleapis.com/v1/projects/PROJECT_ID/messages:send`).
/// Audience maps to a topic or condition; `imageUrl` maps to
/// `message.notification.image`.
///
/// **In-app dialog does NOT map onto Firebase In-App Messaging.** FIAM
/// campaigns can only be authored in the Firebase console — Google ships no
/// Admin SDK or REST API for creating them, so an admin panel physically
/// cannot drive FIAM. In-app dialogs are therefore stored as documents the
/// app reads and renders itself. [InAppLayout] deliberately mirrors FIAM's
/// layout vocabulary so the two stay conceptually interchangeable.
library;

enum PushAudience { all, free, premium, bangladesh }

enum PushStatus { draft, sent }

/// Push and in-app are separate delivery systems, not two skins of one thing:
/// push is delivered by the OS while the app is closed, in-app is rendered by
/// the app itself on next foreground. [both] writes to each path.
enum NotificationChannel { push, inApp, both }

/// Mirrors Firebase In-App Messaging's layouts so the vocabulary matches what
/// the client renders.
enum InAppLayout { modal, card, banner, imageOnly }

extension NotificationChannelX on NotificationChannel {
  String get label => switch (this) {
    NotificationChannel.push => 'Push',
    NotificationChannel.inApp => 'In-App',
    NotificationChannel.both => 'Push + In-App',
  };

  String get blurb => switch (this) {
    NotificationChannel.push =>
      'Delivered by the OS. Arrives even when the app is closed.',
    NotificationChannel.inApp =>
      'Rendered by the app on next open. Richer, but only reaches users who '
          'launch the app.',
    NotificationChannel.both =>
      'Push to pull users back, and a dialog waiting when they arrive.',
  };

  bool get hasPush => this != NotificationChannel.inApp;

  bool get hasInApp => this != NotificationChannel.push;
}

extension InAppLayoutX on InAppLayout {
  String get label => switch (this) {
    InAppLayout.modal => 'Modal',
    InAppLayout.card => 'Card',
    InAppLayout.banner => 'Banner',
    InAppLayout.imageOnly => 'Image only',
  };

  /// Banners are a thin strip, so long bodies are dropped by the client.
  bool get showsBody => this != InAppLayout.imageOnly;

  bool get requiresImage => this == InAppLayout.imageOnly;
}

/// Android truncates past roughly this on the lock screen.
const kPushTitleSoftLimit = 65;

/// Beyond this the tray collapses the body to a single line.
const kPushBodySoftLimit = 240;

/// FCM rejects images above 1 MB on Android; 2:1 renders without cropping.
const kRecommendedImageNote = '1024×512 (2:1), HTTPS, under 1 MB';

class PushNotification {
  const PushNotification({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.bodyBn,
    required this.bodyEn,
    required this.audience,
    this.channel = NotificationChannel.push,
    this.inAppLayout = InAppLayout.modal,
    this.imageUrl,
    this.actionLabelBn,
    this.actionLabelEn,
    this.actionUrl,
    this.status = PushStatus.draft,
    this.sentAt,
    this.delivered = 0,
    this.opened = 0,
  });

  final String id;
  final String titleBn;
  final String titleEn;
  final String bodyBn;
  final String bodyEn;
  final PushAudience audience;
  final NotificationChannel channel;

  /// Only meaningful when [channel] includes in-app.
  final InAppLayout inAppLayout;

  /// Public HTTPS URL. Phase 3 uploads to Cloud Storage and stores the
  /// download URL here — `gs://` paths are not fetchable by FCM or by the
  /// client's image loader.
  final String? imageUrl;

  final String? actionLabelBn;
  final String? actionLabelEn;
  final String? actionUrl;

  final PushStatus status;
  final DateTime? sentAt;
  final int delivered;
  final int opened;

  bool get hasImage => (imageUrl ?? '').trim().isNotEmpty;

  bool get hasAction =>
      (actionLabelEn ?? '').trim().isNotEmpty ||
      (actionLabelBn ?? '').trim().isNotEmpty ||
      (actionUrl ?? '').trim().isNotEmpty;

  double get openRate => delivered == 0 ? 0 : opened / delivered * 100;

  /// Blocking problems. A campaign with any of these must not be sent.
  List<String> get issues {
    final out = <String>[];
    if (titleEn.trim().isEmpty || titleBn.trim().isEmpty) {
      out.add('Both বাংলা and English titles are required.');
    }
    final needsBody = channel.hasPush || inAppLayout.showsBody;
    if (needsBody && (bodyEn.trim().isEmpty || bodyBn.trim().isEmpty)) {
      out.add('Both বাংলা and English bodies are required.');
    }
    if (channel.hasInApp && inAppLayout.requiresImage && !hasImage) {
      out.add('The “Image only” layout needs an image.');
    }
    if (hasImage && !imageUrl!.trim().startsWith('https://')) {
      // FCM silently drops non-HTTPS images rather than erroring.
      out.add('Image URL must start with https://');
    }
    final hasLabel =
        (actionLabelEn ?? '').trim().isNotEmpty ||
        (actionLabelBn ?? '').trim().isNotEmpty;
    final hasUrl = (actionUrl ?? '').trim().isNotEmpty;
    if (hasLabel != hasUrl) {
      out.add('An action button needs both a label and a destination.');
    }
    return out;
  }

  bool get canSend => issues.isEmpty;

  /// Non-blocking advice — things that still send but render badly.
  List<String> get warnings {
    final out = <String>[];
    if (channel.hasPush && titleEn.trim().length > kPushTitleSoftLimit) {
      out.add(
        'English title is ${titleEn.trim().length} characters; Android '
        'truncates past $kPushTitleSoftLimit on the lock screen.',
      );
    }
    if (channel.hasPush && bodyEn.trim().length > kPushBodySoftLimit) {
      out.add(
        'English body is long; the notification tray will collapse it until '
        'expanded.',
      );
    }
    if (channel.hasPush && hasImage) {
      // The single most common "the image just doesn't show" cause on iOS.
      out.add(
        'iOS only renders push images when the app ships a Notification '
        'Service Extension. Android and web need nothing extra.',
      );
    }
    return out;
  }

  PushNotification copyWith({
    String? titleBn,
    String? titleEn,
    String? bodyBn,
    String? bodyEn,
    PushAudience? audience,
    NotificationChannel? channel,
    InAppLayout? inAppLayout,
    String? imageUrl,
    bool clearImage = false,
    String? actionLabelBn,
    String? actionLabelEn,
    String? actionUrl,
    PushStatus? status,
    DateTime? sentAt,
    int? delivered,
    int? opened,
  }) => PushNotification(
    id: id,
    titleBn: titleBn ?? this.titleBn,
    titleEn: titleEn ?? this.titleEn,
    bodyBn: bodyBn ?? this.bodyBn,
    bodyEn: bodyEn ?? this.bodyEn,
    audience: audience ?? this.audience,
    channel: channel ?? this.channel,
    inAppLayout: inAppLayout ?? this.inAppLayout,
    imageUrl: clearImage ? null : (imageUrl ?? this.imageUrl),
    actionLabelBn: actionLabelBn ?? this.actionLabelBn,
    actionLabelEn: actionLabelEn ?? this.actionLabelEn,
    actionUrl: actionUrl ?? this.actionUrl,
    status: status ?? this.status,
    sentAt: sentAt ?? this.sentAt,
    delivered: delivered ?? this.delivered,
    opened: opened ?? this.opened,
  );
}
