/// Reminder kinds a user can track in the Joba app.
/// Enum order is the global home-screen planning sequence;
/// admins can rearrange it.
enum ReminderKind {
  pad,
  periodPrep,
  medicine;

  String get label => switch (this) {
        ReminderKind.pad => 'Pad reminder',
        ReminderKind.periodPrep => 'Period preparation',
        ReminderKind.medicine => 'Medicine reminder',
      };

  String get labelBn => switch (this) {
        ReminderKind.pad => 'প্যাড রিমাইন্ডার',
        ReminderKind.periodPrep => 'পিরিয়ড প্রস্তুতি',
        ReminderKind.medicine => 'ঔষধ রিমাইন্ডার',
      };

  /// When the reminder fires on the user's home screen planning.
  String get scheduleLabel => switch (this) {
        ReminderKind.pad => 'Get pad reminder every 6 hours',
        ReminderKind.periodPrep => 'Be prepared before your period',
        ReminderKind.medicine => 'Daily • user-chosen time',
      };
}