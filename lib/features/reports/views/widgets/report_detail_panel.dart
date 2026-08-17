import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
import 'package:joba_admin/features/reports/views/widgets/report_type_icon.dart';

/// Helper to open the full detail slide-over panel for a report.
void openReportDetailPanel(BuildContext context, String reportId) {
  showDetailPanel(
    context,
    title: 'Report Details',
    child: ReportDetailBody(id: reportId),
    footer: ReportDetailFooter(id: reportId),
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
                      Text(
                        r.subject,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
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
                        r.userEmail,
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
                      reportPriorityBadge(r.priority),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionLabel(context, 'Description'),
            const SizedBox(height: 6),
            Text(
              r.description,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            _sectionLabel(context, 'Screenshots (2)'),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final c in [AppColors.accent, AppColors.primary])
                  Container(
                    width: 84,
                    height: 120,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      Icons.phone_android,
                      color: c.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionLabel(context, 'Device Info'),
            const SizedBox(height: 6),
            Text(
              '${r.deviceModel ?? 'Unknown'} • ${r.os ?? '—'}',
              style: TextStyle(color: palette.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 18),
            _sectionLabel(context, 'History'),
            const SizedBox(height: 8),
            _historyRow(
              context,
              formatDateTime(r.date),
              'Report submitted by user',
            ),
            if (r.status != ReportStatus.pending)
              _historyRow(
                context,
                formatDateTime(r.date.add(const Duration(hours: 5))),
                'Status changed to ${r.status.displayName}',
              ),
          ],
        ),
      );
    });
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
    return Obx(() {
      final r = controller.all.firstWhereOrNull((e) => e.id == id);
      if (r == null) return const SizedBox();

      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.snackbar(
                'Assigned',
                'Report assigned to support team (mock).',
                snackPosition: SnackPosition.BOTTOM,
              ),
              icon: const Icon(Icons.person_add_alt_outlined, size: 16),
              label: const Text('Assign to Team'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PopupMenuButton<ReportStatus>(
              onSelected: (status) {
                controller.updateStatus(id, status);
                Get.snackbar(
                  'Status updated',
                  'Report marked as ${status.displayName} (mock).',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
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
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
