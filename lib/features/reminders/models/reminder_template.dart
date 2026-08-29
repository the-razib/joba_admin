import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

/// Global reminders configuration model for sequence & settings.
class ReminderTemplate {
  const ReminderTemplate({
    required this.id,
    required this.order,
    this.updatedAt,
    this.updatedBy,
  });

  final String id;
  final List<ReminderKind> order;
  final DateTime? updatedAt;
  final String? updatedBy;

  Map<String, dynamic> toMap() {
    return {
      'order': order.map((k) => k.name).toList(),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }

  factory ReminderTemplate.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawOrder = map['order'] as List?;
    final list = <ReminderKind>[];
    if (rawOrder != null) {
      for (final item in rawOrder) {
        final kind = ReminderKind.values.firstWhereOrNull((k) => k.name == item?.toString());
        if (kind != null) list.add(kind);
      }
    }
    if (list.isEmpty) {
      list.addAll([ReminderKind.pad, ReminderKind.periodPrep, ReminderKind.medicine]);
    }

    return ReminderTemplate(
      id: docId ?? 'reminders',
      order: list,
      updatedAt: parseDate(map['updatedAt']),
      updatedBy: map['updatedBy']?.toString(),
    );
  }
}