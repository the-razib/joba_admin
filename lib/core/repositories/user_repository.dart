import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';

/// Phase 1: mock seed. Phase 3: `FirebaseUserRepository` reads `users/{uid}`.
abstract class UserRepository {
  Future<List<AppUser>> seedUsers();
  Future<List<AppUser>> fetchUsers({int limit = 100});
  Future<AppUser?> getUser(String uid);
  Future<void> updateUserStatus(String uid, UserStatus status);
  Future<void> updateUserPlan(String uid, UserPlan plan);
  Future<void> deleteUser(String uid);
}

class MockUserRepository implements UserRepository {
  List<AppUser>? _cachedUsers;

  @override
  Future<List<AppUser>> seedUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;
    final now = DateTime.now();
    DateTime d(int days, [int hour = 10, int minute = 30]) =>
        now.subtract(Duration(days: days)).copyWith(hour: hour, minute: minute);

    _cachedUsers = [
      AppUser(
        uid: 'f7h8d9k3j2',
        name: 'Farhana Akter',
        email: 'farhanaakter@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.premium,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: d(81),
        lastActive: now.subtract(const Duration(minutes: 2)),
        language: 'bn',
        averageCycleLength: 28,
        averagePeriodDuration: 5,
        cycleGoal: 'track',
        birthYear: 1998,
        reminders: [
          ReminderKind.pad,
          ReminderKind.periodPrep,
          ReminderKind.medicine,
        ],
      ),
      AppUser(
        uid: 'a8j9k3l2m4',
        name: 'Meherun Nisa',
        email: 'meherun.nisa@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.free,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: d(81, 9, 15),
        lastActive: now.subtract(const Duration(minutes: 15)),
        language: 'bn',
        averageCycleLength: 30,
        averagePeriodDuration: 6,
        cycleGoal: 'track',
        birthYear: 2001,
        reminders: [ReminderKind.pad, ReminderKind.periodPrep],
      ),
      AppUser(
        uid: 'n3k2l4m5p1',
        name: 'Nusrat Jahan',
        email: 'nusrat.jahan12@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.free,
        country: 'India',
        countryCode: 'IN',
        joinedAt: d(81, 8, 45),
        lastActive: now.subtract(const Duration(minutes: 28)),
        language: 'en',
        averageCycleLength: 27,
        averagePeriodDuration: 4,
        cycleGoal: 'conceive',
        birthYear: 2009,
        reminders: [ReminderKind.pad],
      ),
      AppUser(
        uid: 't6j7h8j9k1',
        name: 'Tania Ahmed',
        email: 'tania.ahmed@gmail.com',
        status: UserStatus.inactive,
        plan: UserPlan.premium,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: d(82, 11, 20),
        lastActive: now.subtract(const Duration(days: 2)),
        language: 'bn',
        averageCycleLength: 26,
        averagePeriodDuration: 5,
        cycleGoal: 'avoid',
        birthYear: 1995,
        reminders: [ReminderKind.pad, ReminderKind.periodPrep],
      ),
      AppUser(
        uid: 's9d8f7g6h2',
        name: 'Sadia Islam',
        email: 'sadia.islam@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.premium,
        country: 'Pakistan',
        countryCode: 'PK',
        joinedAt: d(82, 18, 30),
        lastActive: now.subtract(const Duration(minutes: 5)),
        language: 'en',
        averageCycleLength: 29,
        averagePeriodDuration: 5,
        cycleGoal: 'track',
        birthYear: 2003,
        reminders: [ReminderKind.periodPrep, ReminderKind.medicine],
      ),
      AppUser(
        uid: 'r2t4y6u8i9',
        name: 'Riya Dey',
        email: 'riya.dey@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.free,
        country: 'India',
        countryCode: 'IN',
        joinedAt: d(82, 17, 10),
        lastActive: now.subtract(const Duration(hours: 1)),
        language: 'en',
        averageCycleLength: 31,
        averagePeriodDuration: 6,
        cycleGoal: 'track',
        birthYear: 2005,
        reminders: [ReminderKind.pad, ReminderKind.medicine],
      ),
      AppUser(
        uid: 'm1n2b3v4c5',
        name: 'Mou Akter',
        email: 'mou.akter@gmail.com',
        status: UserStatus.blocked,
        plan: UserPlan.free,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: d(83, 21, 40),
        lastActive: now.subtract(const Duration(days: 7)),
        language: 'bn',
        averageCycleLength: 28,
        averagePeriodDuration: 5,
        cycleGoal: 'track',
        birthYear: 1996,
        reminders: [],
      ),
      AppUser(
        uid: 'q1w2e3r4t5',
        name: 'Ayesha Rahman',
        email: 'ayesha.rahman@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.premium,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: d(90, 12, 0),
        lastActive: now.subtract(const Duration(minutes: 42)),
        language: 'bn',
        averageCycleLength: 28,
        averagePeriodDuration: 4,
        cycleGoal: 'conceive',
        birthYear: 1992,
        reminders: [
          ReminderKind.pad,
          ReminderKind.periodPrep,
          ReminderKind.medicine,
        ],
      ),
      AppUser(
        uid: 'z1x2c3v4b5',
        name: 'Fatema Begum',
        email: 'fatema.begum@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.free,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: d(104, 15, 25),
        lastActive: now.subtract(const Duration(hours: 3)),
        language: 'bn',
        averageCycleLength: 32,
        averagePeriodDuration: 7,
        cycleGoal: 'track',
        birthYear: 1993,
        reminders: [ReminderKind.periodPrep, ReminderKind.medicine],
      ),
      AppUser(
        uid: 'p0o9i8u7y6',
        name: 'Priya Das',
        email: 'priya.das@gmail.com',
        status: UserStatus.inactive,
        plan: UserPlan.free,
        country: 'India',
        countryCode: 'IN',
        joinedAt: d(120, 9, 5),
        lastActive: now.subtract(const Duration(days: 12)),
        language: 'en',
        averageCycleLength: 27,
        averagePeriodDuration: 5,
        cycleGoal: 'track',
        birthYear: 1988,
        reminders: [ReminderKind.pad],
      ),
      AppUser(
        uid: 'l1k2j3h4g5',
        name: 'Lima Khatun',
        email: 'lima.khatun@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.premium,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: d(133, 19, 45),
        lastActive: now.subtract(const Duration(minutes: 8)),
        language: 'bn',
        averageCycleLength: 29,
        averagePeriodDuration: 5,
        cycleGoal: 'track',
        birthYear: 1979,
        reminders: [
          ReminderKind.pad,
          ReminderKind.periodPrep,
          ReminderKind.medicine,
        ],
      ),
      AppUser(
        uid: 'w1s2d3f4g5',
        name: 'Shorna Akter',
        email: 'shorna.akter@gmail.com',
        status: UserStatus.active,
        plan: UserPlan.free,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: d(150, 8, 15),
        lastActive: now.subtract(const Duration(hours: 5)),
        language: 'bn',
        averageCycleLength: 28,
        averagePeriodDuration: 6,
        cycleGoal: 'avoid',
        birthYear: 1986,
        reminders: [ReminderKind.medicine],
      ),
    ];
    return _cachedUsers!;
  }

  @override
  Future<List<AppUser>> fetchUsers({int limit = 100}) async {
    return seedUsers();
  }

  @override
  Future<AppUser?> getUser(String uid) async {
    final list = await seedUsers();
    return list.where((u) => u.uid == uid).firstOrNull;
  }

  @override
  Future<void> updateUserStatus(String uid, UserStatus status) async {
    final list = await seedUsers();
    final index = list.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      list[index] = list[index].copyWith(status: status);
    }
  }

  @override
  Future<void> updateUserPlan(String uid, UserPlan plan) async {
    final list = await seedUsers();
    final index = list.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      list[index] = list[index].copyWith(plan: plan);
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    final list = await seedUsers();
    list.removeWhere((u) => u.uid == uid);
  }
}
