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
    if (runes.length != 2) return 'ðŸŒ';
    const base = 0x1F1E6; // regional indicator A
    return String.fromCharCode(base + runes.first - 65) +
        String.fromCharCode(base + runes.last - 65);
  }

  AppUser copyWith({
    UserStatus? status,
    UserPlan? plan,
    List<ReminderKind>? reminders,
  }) =>
      AppUser(
        uid: uid,
        name: name,
        email: email,
        photoUrl: photoUrl,
        status: status ?? this.status,
        plan: plan ?? this.plan,
        country: country,
        countryCode: countryCode,
        joinedAt: joinedAt,
        lastActive: lastActive,
        language: language,
        averageCycleLength: averageCycleLength,
        averagePeriodDuration: averagePeriodDuration,
        cycleGoal: cycleGoal,
        birthYear: birthYear,
        reminders: reminders ?? this.reminders,
      );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'status': status.name,
      'plan': plan.name,
      'country': country,
      'countryCode': countryCode,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastActive': Timestamp.fromDate(lastActive),
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

    final statusStr = map['status']?.toString().toLowerCase() ?? 'active';
    final userStatus = UserStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => UserStatus.active,
    );

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

    return AppUser(
      uid: docId ?? map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? map['displayName']?.toString() ?? 'User',
      email: map['email']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? map['photoURL']?.toString(),
      status: userStatus,
      plan: userPlan,
      country: map['country']?.toString() ?? 'Bangladesh',
      countryCode: map['countryCode']?.toString() ?? 'BD',
      joinedAt: parseDate(map['joinedAt'] ?? map['createdAt']),
      lastActive: parseDate(map['lastActive'] ?? map['updatedAt']),
      language: map['language']?.toString() ?? 'bn',
      averageCycleLength: (map['averageCycleLength'] as num?)?.toInt() ?? 28,
      averagePeriodDuration: (map['averagePeriodDuration'] as num?)?.toInt() ?? 5,
      cycleGoal: map['cycleGoal']?.toString() ?? 'track',
      birthYear: (map['birthYear'] as num?)?.toInt(),
      reminders: remindersList,
    );
  }
}