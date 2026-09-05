import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/features/reports/views/widgets/report_type_icon.dart';

/// Helper to open the full detail slide-over panel for a report.
void openReportDetailPanel(BuildContext context, String reportId) {
  final bool canManage = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>().canManageContent
      : true;

  try {
    Get.find<ReportsController>().markAsRead(reportId);
  } catch (_) {}

  showDetailPanel(
    context,
    title: 'Report Details',
    child: ReportDetailBody(id: reportId),
    footer: canManage ? ReportDetailFooter(id: reportId) : null,
  );
}

/// The body content of the report detail drawer.
class ReportDetailBody extends GetView<ReportsController> {
  final String id;

  const ReportDetailBody({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = controller.all.firstWhereOrNull((e) => e.id == id);
      if (r == null) return const SizedBox();
      final palette = context.palette;
      final bool canManage = Get.isRegistered<AuthService>()
          ? Get.find<AuthService>().canManageContent
          : true;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReportTypeIcon(type: r.type, size: 44, iconSize: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!r.isRead) ...[
                            reportNewBadge(),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              r.subject,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '#${r.id} • ${formatDateTime(r.date)}',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                reportStatusBadge(r.status),
              ],
            ),
            const SizedBox(height: 18),
            _sectionLabel(context, 'Reported by'),
            const SizedBox(height: 8),
            Row(
              children: [
                AvatarCircle(name: r.userName, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.userName,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        r.userEmail.isNotEmpty
                            ? r.userEmail
                            : (r.uid != null ? 'UID: ${r.uid}' : 'Anonymous'),
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel(context, 'Report Type'),
                      const SizedBox(height: 6),
                      reportTypeBadge(r.type),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel(context, 'Priority'),
                      const SizedBox(height: 6),
                      if (canManage)
                        PopupMenuButton<ReportPriority>(
                          onSelected: (p) => controller.updatePriority(id, p),
                          tooltip: 'Change Priority',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              reportPriorityBadge(r.priority),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: palette.textSecondary,
                              ),
                            ],
                          ),
                          itemBuilder: (_) => [
                            for (final p in ReportPriority.values)
                              PopupMenuItem(
                                value: p,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: p.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(p.displayName),
                                  ],
                                ),
                              ),
                          ],
                        )
                      else
                        reportPriorityBadge(r.priority),
                    ],
                  ),
                ),
              ],
            ),
            if (r.issues.isNotEmpty) ...[
              const SizedBox(height: 18),
              _sectionLabel(context, 'Selected Issues'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final issue in r.issues)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        issue,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            _sectionLabel(context, 'Description'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.border),
              ),
              child: Text(
                r.description.isNotEmpty ? r.description : 'No description provided.',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _sectionLabel(context, 'Device & Environment'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  _deviceInfoRow(
                    context,
                    Icons.phone_android_outlined,
                    'Device Model',
                    r.deviceModel ?? 'Unknown',
                  ),
                  const Divider(height: 16),
                  _deviceInfoRow(
                    context,
                    Icons.settings_system_daydream_outlined,
                    'Operating System',
                    r.os ?? 'Unknown',
                  ),
                  if (r.appVersion != null) ...[
                    const Divider(height: 16),
                    _deviceInfoRow(
                      context,
                      Icons.apps_outlined,
                      'App Version',
                      'v${r.appVersion}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _sectionLabel(context, 'Timeline'),
            const SizedBox(height: 8),
            _historyRow(
              context,
              formatDateTime(r.date),
              'Report submitted by user',
            ),
            if (r.status != ReportStatus.pending)
              _historyRow(
                context,
                'Current Status',
                'Status is ${r.status.displayName}',
              ),
          ],
        ),
      );
    });
  }

  Widget _deviceInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final palette = context.palette;
    return Row(
      children: [
        Icon(icon, size: 16, color: palette.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: palette.textSecondary, fontSize: 12),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String title) => Text(
        title,
        style: TextStyle(
          color: context.palette.textPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _historyRow(BuildContext context, String time, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

/// The footer actions of the report detail drawer.
class ReportDetailFooter extends GetView<ReportsController> {
  final String id;

  const ReportDetailFooter({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final bool isSuper = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageAdmins
        : true;

    return Obx(() {
      final r = controller.all.firstWhereOrNull((e) => e.id == id);
      if (r == null) return const SizedBox();

      return Row(
        children: [
          if (isSuper) ...[
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, r),
              icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
              label: const Text('Delete', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: PopupMenuButton<ReportStatus>(
              onSelected: (status) => controller.updateStatus(id, status),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Update Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
              itemBuilder: (_) => [
                for (final s in ReportStatus.values)
                  PopupMenuItem(
                    value: s,
                    child: Text(
                      s.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            r.status == s ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _confirmDelete(BuildContext context, Report report) {
    Get.defaultDialog(
      title: 'Delete Report',
      middleText: 'Are you sure you want to delete this report from ${report.userName}?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () {
        Get.back(); // close dialog
        Get.back(); // close slide-over panel
        controller.deleteReport(report.id);
      },
    );
  }
}
