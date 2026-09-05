import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/notifications/models/admin_notification_item.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/features/shell/nav_items.dart';

class AdminNotificationsController extends GetxController {
  ReportRepository get _reportRepo =>
      Get.isRegistered<ReportRepository>()
          ? Get.find<ReportRepository>()
          : MockReportRepository();

  AuditLogRepository get _auditRepo =>
      Get.isRegistered<AuditLogRepository>()
          ? Get.find<AuditLogRepository>()
          : MockAuditLogRepository();

  final notifications = <AdminNotificationItem>[].obs;
  final isLoading = false.obs;
  final activeFilter = NotificationCategory.all.obs;
  final readIds = <String>{}.obs;

  StreamSubscription? _reportsSub;

  int get unreadCount =>
      notifications.where((n) => !n.isRead && !readIds.contains(n.id)).length;

  List<AdminNotificationItem> get filteredNotifications {
    final filter = activeFilter.value;
    if (filter == NotificationCategory.all) {
      return notifications;
    }
    return notifications.where((n) => n.category == filter).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    _initRealtimeListener();
  }

  @override
  void onClose() {
    _reportsSub?.cancel();
    super.onClose();
  }

  void _initRealtimeListener() {
    if (Firebase.apps.isEmpty) return;
    try {
      _reportsSub = FirebaseFirestore.instance
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(25)
          .snapshots()
          .listen((snap) {
        if (snap.docs.isNotEmpty) {
          final liveReports = snap.docs.map((d) {
            return Report.fromMap(d.data(), docId: d.id);
          }).toList();
          _mergeReports(liveReports);
        }
      }, onError: (e) {
        AppLoggerHelper.warning('[AdminNotifications] Firestore snapshots warning: $e');
      });
    } catch (e) {
      AppLoggerHelper.warning('[AdminNotifications] Realtime listener skipped: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      AppLoggerHelper.info('[AdminNotifications] 🔔 Fetching administrative notifications...');

      // 1. Fetch user problem reports from mobile
      final reports = await _reportRepo.fetchReports(limit: 25);
      final reportItems = reports.map(_mapReportToNotification).toList();

      // 2. Fetch security alerts from audit logs
      List<AdminNotificationItem> securityItems = [];
      try {
        final logs = await _auditRepo.fetchLogs(limit: 20);
        final alertLogs = logs.where(
          (l) => l.action == AuditAction.failedLogin || l.status == AuditStatus.failed,
        );
        securityItems = alertLogs.map(_mapLogToNotification).toList();
      } catch (e) {
        AppLoggerHelper.warning('[AdminNotifications] Audit logs fetch skipped: $e');
      }

      final combined = [...reportItems, ...securityItems];
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Fallback seed if completely empty
      if (combined.isEmpty) {
        combined.addAll(_fallbackSeedItems());
      }

      notifications.assignAll(combined);
      AppLoggerHelper.success(
        'AdminNotifications',
        'Loaded ${notifications.length} notifications ($unreadCount unread)',
      );
    } catch (e, st) {
      AppLoggerHelper.failure('AdminNotifications', 'Failed to load notifications: $e', error: e, stackTrace: st);
      if (notifications.isEmpty) {
        notifications.assignAll(_fallbackSeedItems());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _mergeReports(List<Report> reports) {
    final reportItems = reports.map(_mapReportToNotification).toList();
    final nonReports = notifications
        .where((n) => n.category != NotificationCategory.report)
        .toList();

    final combined = [...reportItems, ...nonReports];
    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifications.assignAll(combined);
  }

  AdminNotificationItem _mapReportToNotification(Report r) {
    final isRead = r.isRead || readIds.contains(r.id);

    return AdminNotificationItem(
      id: r.id,
      title: r.subject.isNotEmpty ? r.subject : r.type.displayName,
      message: r.description,
      subtitle: '${r.userName} • ${r.deviceModel ?? "Mobile App"}',
      timestamp: r.date,
      category: NotificationCategory.report,
      isRead: isRead,
      icon: r.type.icon,
      color: r.type.color,
      reportId: r.id,
      targetNav: NavId.reports,
    );
  }

  AdminNotificationItem _mapLogToNotification(AuditLog l) {
    final isRead = readIds.contains(l.id);

    return AdminNotificationItem(
      id: l.id,
      title: 'Security Alert: ${l.action.label}',
      message: l.details,
      subtitle: '${l.adminName} • Authentication Trail',
      timestamp: l.time,
      category: NotificationCategory.security,
      isRead: isRead,
      icon: Icons.shield_outlined,
      color: AppColors.danger,
      targetNav: NavId.audit,
    );
  }

  List<AdminNotificationItem> _fallbackSeedItems() {
    final now = DateTime.now();
    return [
      AdminNotificationItem(
        id: 'seed-01',
        title: 'Prediction Discrepancy Reported',
        message: 'Ovulation window predicted 3 days earlier than basal temperature peak.',
        subtitle: 'Fatima Rahman • Samsung S23 (Android 14)',
        timestamp: now.subtract(const Duration(minutes: 18)),
        category: NotificationCategory.report,
        isRead: false,
        icon: Icons.analytics_outlined,
        color: AppColors.purple,
        targetNav: NavId.reports,
      ),
      AdminNotificationItem(
        id: 'seed-02',
        title: 'Security: Failed Admin Login',
        message: 'Invalid password entered 3 times from IP 103.145.74.22',
        subtitle: 'staff@joba.app • Security Gateway',
        timestamp: now.subtract(const Duration(hours: 2)),
        category: NotificationCategory.security,
        isRead: false,
        icon: Icons.shield_outlined,
        color: AppColors.danger,
        targetNav: NavId.audit,
      ),
      AdminNotificationItem(
        id: 'seed-03',
        title: 'Article Audio Narration Feedback',
        message: 'Bangla narration cuts off before the last tip paragraph on PCOS article.',
        subtitle: 'Nusrat Jahan • iPhone 14 Pro',
        timestamp: now.subtract(const Duration(hours: 5)),
        category: NotificationCategory.report,
        isRead: true,
        icon: Icons.article_outlined,
        color: AppColors.info,
        targetNav: NavId.reports,
      ),
    ];
  }

  /// Mark single notification as read
  Future<void> markAsRead(String id) async {
    readIds.add(id);
    final i = notifications.indexWhere((n) => n.id == id);
    if (i >= 0) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }

    final item = i >= 0 ? notifications[i] : null;
    if (item?.reportId != null) {
      try {
        await _reportRepo.markAsRead(item!.reportId!);
      } catch (_) {}
    }
  }

  /// Mark all current notifications as read
  Future<void> markAllAsRead() async {
    for (final n in notifications) {
      readIds.add(n.id);
      if (n.reportId != null) {
        _reportRepo.markAsRead(n.reportId!).catchError((_) {});
      }
    }

    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
    AppToast.info('Notifications', 'All notifications marked as read.');
  }

  void setFilter(NotificationCategory category) {
    activeFilter.value = category;
  }
}
