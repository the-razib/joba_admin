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
}