import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

enum ReportType {
  bug,
  prediction,
  content,
  feature,
  payment,
  other;

  IconData get icon => switch (this) {
        ReportType.bug => Icons.bug_report_outlined,
        ReportType.prediction => Icons.analytics_outlined,
        ReportType.content => Icons.article_outlined,
        ReportType.feature => Icons.lightbulb_outline,
        ReportType.payment => Icons.payment_outlined,
        ReportType.other => Icons.help_outline,
      };

  Color get color => switch (this) {
        ReportType.bug => AppColors.danger,
        ReportType.prediction => AppColors.purple,
        ReportType.content => AppColors.info,
        ReportType.feature => AppColors.accent,
        ReportType.payment => AppColors.warning,
        ReportType.other => Colors.grey,
      };

  String get displayName => switch (this) {
        ReportType.bug => 'Bug Report',
        ReportType.prediction => 'Prediction Issue',
        ReportType.content => 'Content Error',
        ReportType.feature => 'Feature Request',
        ReportType.payment => 'Payment Issue',
        ReportType.other => 'Other',
      };
}

enum ReportStatus {
  pending,
  inProgress,
  resolved;

  String get displayName => switch (this) {
        ReportStatus.pending => 'Pending',
        ReportStatus.inProgress => 'In Progress',
        ReportStatus.resolved => 'Resolved',
      };

  Color get color => switch (this) {
        ReportStatus.pending => AppColors.warning,
        ReportStatus.inProgress => AppColors.info,
        ReportStatus.resolved => AppColors.success,
      };
}

enum ReportPriority {
  low,
  medium,
  high;

  String get displayName => switch (this) {
        ReportPriority.low => 'Low',
        ReportPriority.medium => 'Medium',
        ReportPriority.high => 'High',
      };

  Color get color => switch (this) {
        ReportPriority.low => AppColors.info,
        ReportPriority.medium => AppColors.warning,
        ReportPriority.high => AppColors.danger,
      };
}

/// Mirrors submissions from the app's Report Problem screen.
class Report {
  const Report({
    required this.id,
    required this.type,
    required this.subject,
    required this.description,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.priority,
    required this.date,
    this.deviceModel,
    this.os,
  });

  final String id;
  final ReportType type;
  final String subject;
  final String description;
  final String userName;
  final String userEmail;
  final ReportStatus status;
  final ReportPriority priority;
  final DateTime date;
  final String? deviceModel;
  final String? os;

  Report copyWith({ReportStatus? status, ReportPriority? priority}) => Report(
        id: id,
        type: type,
        subject: subject,
        description: description,
        userName: userName,
        userEmail: userEmail,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        date: date,
        deviceModel: deviceModel,
        os: os,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'subject': subject,
      'description': description,
      'userName': userName,
      'userEmail': userEmail,
      'status': status.name,
      'priority': priority.name,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(date),
      if (deviceModel != null) 'deviceModel': deviceModel,
      if (os != null) 'os': os,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final typeStr = map['type']?.toString().toLowerCase() ?? 'other';
    final reportType = ReportType.values.firstWhere(
      (t) => t.name.toLowerCase() == typeStr,
      orElse: () => ReportType.other,
    );

    final statusStr = map['status']?.toString().toLowerCase() ?? 'pending';
    final reportStatus = ReportStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == statusStr,
      orElse: () => ReportStatus.pending,
    );

    final prioStr = map['priority']?.toString().toLowerCase() ?? 'medium';
    final reportPriority = ReportPriority.values.firstWhere(
      (p) => p.name.toLowerCase() == prioStr,
      orElse: () => ReportPriority.medium,
    );

    return Report(
      id: docId ?? map['id']?.toString() ?? '',
      type: reportType,
      subject: map['subject']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Anonymous',
      userEmail: map['userEmail']?.toString() ?? '',
      status: reportStatus,
      priority: reportPriority,
      date: parseDate(map['date'] ?? map['createdAt']),
      deviceModel: map['deviceModel']?.toString(),
      os: map['os']?.toString(),
    );
  }
}
