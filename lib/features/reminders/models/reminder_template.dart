import 'package:flutter/material.dart';

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

  Color get themeColor => switch (this) {
        ReminderKind.pad => const Color(0xFF7B61FF),
        ReminderKind.periodPrep => const Color(0xFFE65671),
        ReminderKind.medicine => const Color(0xFF00BCD4),
      };

  bool get isSvg => switch (this) {
        ReminderKind.pad => true,
        ReminderKind.periodPrep => true,
        ReminderKind.medicine => false,
      };

  String get assetPath => switch (this) {
        ReminderKind.pad => 'assets/icons/home/pad_reminder.svg',
        ReminderKind.periodPrep => 'assets/icons/home/period_preparation.svg',
        ReminderKind.medicine => 'assets/icons/reminder/medicine_reminder.png',
      };

  String get previewShortTitle => switch (this) {
        ReminderKind.pad => 'প্যাড',
        ReminderKind.periodPrep => 'প্রস্তুতি',
        ReminderKind.medicine => 'মেডিসিন',
      };
}