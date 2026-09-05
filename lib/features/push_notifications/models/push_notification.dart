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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

enum PushAudience { all, free, premium, bangladesh }

enum PushStatus { draft, sending, sent, failed }

extension PushStatusX on PushStatus {
  String get label => switch (this) {
    PushStatus.draft => 'Draft',
    PushStatus.sending => 'Sending',
    PushStatus.sent => 'Sent',
    PushStatus.failed => 'Failed',
  };

  /// Whether a dispatch may be started from this state.
  bool get isDispatchable =>
      this == PushStatus.draft || this == PushStatus.failed;

  /// Whether the campaign has already reached devices at least once.
  bool get isDelivered => this == PushStatus.sent;

  bool get isInFlight => this == PushStatus.sending;
}

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

  Color get color => switch (this) {
    NotificationChannel.push => AppColors.primary,
    NotificationChannel.inApp => AppColors.accent,
    NotificationChannel.both => AppColors.purple,
  };

  IconData get icon => switch (this) {
    NotificationChannel.push => Icons.notifications_active_outlined,
    NotificationChannel.inApp => Icons.chat_bubble_outline,
    NotificationChannel.both => Icons.campaign_outlined,
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
    InAppLayout.modal => 'Dialog',
    InAppLayout.card => 'Card',
    InAppLayout.banner => 'Banner',
    InAppLayout.imageOnly => 'Image only',
  };

  /// Only Dialog (modal) is active; all other layouts are currently locked.
  bool get isLocked => this != InAppLayout.modal;

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
    this.createdAt,
    this.createdBy,
    this.sentCount = 0,
    this.failedCount = 0,
    this.messageId,
    this.errorMessage,
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

  /// Public HTTPS URL, uploaded to Cloud Storage by the composer — `gs://`
  /// paths are not fetchable by FCM or by the client's image loader.
  final String? imageUrl;

  final String? actionLabelBn;
  final String? actionLabelEn;
  final String? actionUrl;

  final PushStatus status;
  final DateTime? sentAt;
  final DateTime? createdAt;

  /// UID of the admin who created the campaign.
  final String? createdBy;

  /// Devices FCM accepted the message for. Written by the Cloud Function.
  final int sentCount;

  /// Devices FCM rejected, mostly stale tokens from uninstalled apps.
  final int failedCount;

  /// Message id of the first accepted send, for cross-referencing in logs.
  final String? messageId;

  /// Why the dispatch failed, when [status] is [PushStatus.failed].
  final String? errorMessage;

  bool get hasImage => (imageUrl ?? '').trim().isNotEmpty;

  bool get hasAction =>
      (actionLabelEn ?? '').trim().isNotEmpty ||
      (actionLabelBn ?? '').trim().isNotEmpty ||
      (actionUrl ?? '').trim().isNotEmpty;

  /// Devices targeted in the last dispatch.
  int get totalAttempted => sentCount + failedCount;

  /// Share of attempted devices FCM accepted.
  double get acceptanceRate =>
      totalAttempted == 0 ? 0 : sentCount / totalAttempted * 100;

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
    String? id,
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
    DateTime? createdAt,
    String? createdBy,
    int? sentCount,
    int? failedCount,
    String? messageId,
    String? errorMessage,
    bool clearError = false,
  }) => PushNotification(
    id: id ?? this.id,
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
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    sentCount: sentCount ?? this.sentCount,
    failedCount: failedCount ?? this.failedCount,
    messageId: messageId ?? this.messageId,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  /// Fields the PANEL owns. Deliberately excludes `status`, `sentAt`,
  /// `sentCount`, `failedCount`, `messageId` and `errorMessage`: those belong to
  /// the Cloud Function, and writing them from the client would let a stale
  /// draft save overwrite a real dispatch result.
  Map<String, dynamic> toDraftMap() {
    return {
      'title': {'bn': titleBn, 'en': titleEn},
      'titleBn': titleBn,
      'titleEn': titleEn,
      'body': {'bn': bodyBn, 'en': bodyEn},
      'bodyBn': bodyBn,
      'bodyEn': bodyEn,
      'audience': audience.name,
      'channel': channel.name,
      'inAppLayout': inAppLayout.name,
      'imageUrl': imageUrl,
      'actionLabel': {'bn': actionLabelBn, 'en': actionLabelEn},
      'actionLabelBn': actionLabelBn,
      'actionLabelEn': actionLabelEn,
      'actionUrl': actionUrl,
      'actionType': (actionUrl ?? '').trim().isEmpty ? 'none' : 'screen',
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      ...toDraftMap(),
      'status': status.name,
      if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (createdBy != null) 'createdBy': createdBy,
      'sentCount': sentCount,
      'failedCount': failedCount,
      if (messageId != null) 'messageId': messageId,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  factory PushNotification.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final titleMap = map['title'] as Map<String, dynamic>?;
    final bodyMap = map['body'] as Map<String, dynamic>?;
    final actionLabelMap = map['actionLabel'] as Map<String, dynamic>?;

    final audStr = map['audience']?.toString().toLowerCase() ?? 'all';
    final pushAudience = PushAudience.values.firstWhere(
      (a) => a.name.toLowerCase() == audStr,
      orElse: () => PushAudience.all,
    );

    final chStr = map['channel']?.toString().toLowerCase() ?? 'push';
    final pushChannel = NotificationChannel.values.firstWhere(
      (c) => c.name.toLowerCase() == chStr,
      orElse: () => NotificationChannel.push,
    );

    final layStr = map['inAppLayout']?.toString().toLowerCase() ?? 'modal';
    final pushLayout = InAppLayout.values.firstWhere(
      (l) => l.name.toLowerCase() == layStr,
      orElse: () => InAppLayout.modal,
    );

    final stStr = map['status']?.toString().toLowerCase() ?? 'draft';
    final pushStatus = PushStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == stStr,
      orElse: () => PushStatus.draft,
    );

    return PushNotification(
      id: docId ?? map['id']?.toString() ?? '',
      titleBn: titleMap?['bn']?.toString() ?? map['titleBn']?.toString() ?? '',
      titleEn: titleMap?['en']?.toString() ?? map['titleEn']?.toString() ?? '',
      bodyBn: bodyMap?['bn']?.toString() ?? map['bodyBn']?.toString() ?? '',
      bodyEn: bodyMap?['en']?.toString() ?? map['bodyEn']?.toString() ?? '',
      audience: pushAudience,
      channel: pushChannel,
      inAppLayout: pushLayout,
      imageUrl: map['imageUrl']?.toString(),
      actionLabelBn: actionLabelMap?['bn']?.toString() ?? map['actionLabelBn']?.toString() ?? '',
      actionLabelEn: actionLabelMap?['en']?.toString() ?? map['actionLabelEn']?.toString() ?? '',
      actionUrl: map['actionUrl']?.toString(),
      status: pushStatus,
      sentAt: parseDate(map['sentAt']),
      createdAt: parseDate(map['createdAt']),
      createdBy: map['createdBy']?.toString(),
      sentCount: (map['sentCount'] as num?)?.toInt() ?? 0,
      failedCount: (map['failedCount'] as num?)?.toInt() ?? 0,
      messageId: map['messageId']?.toString(),
      errorMessage: map['errorMessage']?.toString(),
    );
  }
}
