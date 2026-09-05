import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/features/shell/nav_items.dart';

enum NotificationCategory {
  all('All'),
  report('Reports & Feedback'),
  security('Security Alerts'),
  system('System');

  const NotificationCategory(this.label);
  final String label;

  Color get color => switch (this) {
        NotificationCategory.all => AppColors.primary,
        NotificationCategory.report => AppColors.accent,
        NotificationCategory.security => AppColors.danger,
        NotificationCategory.system => AppColors.info,
      };
}

/// Unified notification item displayed in the admin topbar notification center.
class AdminNotificationItem {
  const AdminNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    required this.icon,
    required this.color,
    this.reportId,
    this.targetNav,
    this.subtitle,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationCategory category;
  final bool isRead;
  final IconData icon;
  final Color color;
  final String? reportId;
  final NavId? targetNav;
  final String? subtitle;

  AdminNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationCategory? category,
    bool? isRead,
    IconData? icon,
    Color? color,
    String? reportId,
    NavId? targetNav,
    String? subtitle,
  }) {
    return AdminNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      reportId: reportId ?? this.reportId,
      targetNav: targetNav ?? this.targetNav,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
