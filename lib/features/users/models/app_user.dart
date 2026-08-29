import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';

enum UserStatus {
  active,
  inactive,
  blocked;

  String get label => switch (this) {
        UserStatus.active => 'Active',
        UserStatus.inactive => 'Inactive',
        UserStatus.blocked => 'Blocked',
      };
}

enum UserPlan {
  free,
  premium;

  String get label => switch (this) {
        UserPlan.free => 'Free',
        UserPlan.premium => 'Premium',
      };
}

/// Mirrors the Joba app's `UserProfile` Firestore document plus
/// admin-side fields (status / plan / country).
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.status,
    required this.plan,
    required this.country,
    required this.countryCode,
    required this.joinedAt,
    required this.lastActive,
    required this.language,
    required this.averageCycleLength,
    required this.averagePeriodDuration,
    required this.cycleGoal,
    this.birthYear,
    this.reminders = const [],
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final UserStatus status;
  final UserPlan plan;
  final String country;
  final String countryCode; // ISO 3166-1 alpha-2, used for flag emoji
  final DateTime joinedAt;
  final DateTime lastActive;
  final String language; // 'bn' | 'en'
  final int averageCycleLength;
  final int averagePeriodDuration;
  final String cycleGoal; // 'track' | 'conceive' | 'avoid'
  final int? birthYear;

  /// Reminder kinds this user tracks, in home-screen planning order.
  final List<ReminderKind> reminders;

  String get flagEmoji {
    final runes = countryCode.toUpperCase().runes;
    if (runes.length != 2) return '🌐';
    const base = 0x1F1E6; // regional indicator A
    return String.fromCharCode(base + runes.first - 65) +
        String.fromCharCode(base + runes.last - 65);
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? photoUrl,
    UserStatus? status,
    UserPlan? plan,
    String? country,
    String? countryCode,
    DateTime? joinedAt,
    DateTime? lastActive,
    String? language,
    int? averageCycleLength,
    int? averagePeriodDuration,
    String? cycleGoal,
    int? birthYear,
    List<ReminderKind>? reminders,
  }) =>
      AppUser(
        uid: uid,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        status: status ?? this.status,
        plan: plan ?? this.plan,
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
        joinedAt: joinedAt ?? this.joinedAt,
        lastActive: lastActive ?? this.lastActive,
        language: language ?? this.language,
        averageCycleLength: averageCycleLength ?? this.averageCycleLength,
        averagePeriodDuration:
            averagePeriodDuration ?? this.averagePeriodDuration,
        cycleGoal: cycleGoal ?? this.cycleGoal,
        birthYear: birthYear ?? this.birthYear,
        reminders: reminders ?? this.reminders,
      );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'displayName': name,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'status': status.name,
      'plan': plan.name,
      'country': country,
      'countryCode': countryCode,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'createdAt': Timestamp.fromDate(joinedAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'lastSeenAt': Timestamp.fromDate(lastActive),
      'language': language,
      'averageCycleLength': averageCycleLength,
      'averagePeriodDuration': averagePeriodDuration,
      'cycleGoal': cycleGoal,
      if (birthYear != null) 'birthYear': birthYear,
      'reminders': reminders.map((r) => r.name).toList(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final lastActiveDate = parseDate(
      map['lastActive'] ?? map['lastSeenAt'] ?? map['updatedAt'],
    );

    final statusStr = map['status']?.toString().toLowerCase();
    UserStatus userStatus;
    if (statusStr == 'blocked') {
      userStatus = UserStatus.blocked;
    } else if (statusStr == 'inactive') {
      userStatus = UserStatus.inactive;
    } else {
      // Automatic Inactivity: 30 days without opening the app (1 full cycle)
      final diff = DateTime.now().difference(lastActiveDate);
      if (diff.inDays >= 30) {
        userStatus = UserStatus.inactive;
      } else {
        userStatus = UserStatus.active;
      }
    }

    final planStr = map['plan']?.toString().toLowerCase() ?? 'free';
    final userPlan = UserPlan.values.firstWhere(
      (p) => p.name == planStr,
      orElse: () => UserPlan.free,
    );

    final remindersRaw = map['reminders'];
    final remindersList = <ReminderKind>[];
    if (remindersRaw is List) {
      for (final item in remindersRaw) {
        final kind = ReminderKind.values.firstWhereOrNull(
          (k) => k.name == item?.toString(),
        );
        if (kind != null) remindersList.add(kind);
      }
    }

    final countryCode = map['countryCode']?.toString().toUpperCase() ?? 'BD';
    final countryName = map['country']?.toString() ?? 'Bangladesh';

    final customName = map['customDisplayName']?.toString();
    final displayName = map['displayName']?.toString();
    final plainName = map['name']?.toString();

    final resolvedName = (customName != null && customName.isNotEmpty)
        ? customName
        : (displayName != null && displayName.isNotEmpty)
            ? displayName
            : (plainName != null && plainName.isNotEmpty)
                ? plainName
                : 'User';

    return AppUser(
      uid: docId ?? map['uid']?.toString() ?? '',
      name: resolvedName,
      email: map['email']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? map['photoURL']?.toString(),
      status: userStatus,
      plan: userPlan,
      country: countryName,
      countryCode: countryCode,
      joinedAt: parseDate(map['joinedAt'] ?? map['createdAt']),
      lastActive: lastActiveDate,
      language: map['language']?.toString() ?? 'bn',
      averageCycleLength: (map['averageCycleLength'] as num?)?.toInt() ?? 28,
      averagePeriodDuration:
          (map['averagePeriodDuration'] as num?)?.toInt() ?? 5,
      cycleGoal: map['cycleGoal']?.toString() ?? 'track',
      birthYear: (map['birthYear'] as num?)?.toInt(),
      reminders: remindersList,
    );
  }
}