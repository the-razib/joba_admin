import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/features/notifications/controllers/admin_notifications_controller.dart';
import 'package:joba_admin/features/notifications/models/admin_notification_item.dart';
import 'package:joba_admin/features/reports/views/widgets/report_detail_panel.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

/// Minimal, high-end administrative notification popover dropdown.
class AdminNotificationsPopover extends StatelessWidget {
  const AdminNotificationsPopover({super.key});

  static Future<void> show(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (ctx) {
        return Align(
          alignment: isMobile ? Alignment.center : Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(
              top: isMobile ? 0 : 64,
              right: isMobile ? 0 : 70,
              left: isMobile ? 16 : 0,
              bottom: isMobile ? 0 : 16,
            ),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? width * 0.94 : 420,
                  maxHeight: 520,
                ),
                child: const AdminNotificationsPopover(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final controller = Get.find<AdminNotificationsController>();

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, controller),
            _buildFilterTabs(context, controller),
            Divider(height: 1, color: palette.border),
            Flexible(child: _buildList(context, controller)),
            Divider(height: 1, color: palette.border),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AdminNotificationsController controller) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              'Notifications',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final unread = controller.unreadCount;
            if (unread == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unread new',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
          const Spacer(),
          Obx(() {
            final unread = controller.unreadCount;
            if (unread == 0) return const SizedBox.shrink();
            return Tooltip(
              message: 'Mark all as read',
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => controller.markAllAsRead(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.done_all, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Mark read',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, AdminNotificationsController controller) {
    final palette = context.palette;

    return Obx(() {
      final currentFilter = controller.activeFilter.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: palette.inputFill.withValues(alpha: 0.25),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip(
                context,
                label: 'All',
                selected: currentFilter == NotificationCategory.all,
                onTap: () => controller.setFilter(NotificationCategory.all),
              ),
              const SizedBox(width: 6),
              _filterChip(
                context,
                label: 'Reports & Feedback',
                selected: currentFilter == NotificationCategory.report,
                onTap: () => controller.setFilter(NotificationCategory.report),
              ),
              const SizedBox(width: 6),
              _filterChip(
                context,
                label: 'Security',
                selected: currentFilter == NotificationCategory.security,
                onTap: () => controller.setFilter(NotificationCategory.security),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final palette = context.palette;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppColors.primary : palette.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : palette.textSecondary,
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, AdminNotificationsController controller) {
    final palette = context.palette;

    return Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      final items = controller.filteredNotifications;

      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none,
                size: 36,
                color: palette.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 10),
              Text(
                'No notifications found',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You are all caught up for this category.',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: palette.border),
        itemBuilder: (ctx, i) {
          final item = items[i];
          return _buildItemRow(context, controller, item);
        },
      );
    });
  }

  Widget _buildItemRow(
    BuildContext context,
    AdminNotificationsController controller,
    AdminNotificationItem item,
  ) {
    final palette = context.palette;
    final isUnread = !item.isRead;

    return InkWell(
      onTap: () {
        controller.markAsRead(item.id);
        Navigator.of(context).pop();

        if (item.reportId != null) {
          openReportDetailPanel(context, item.reportId!);
        } else if (item.targetNav != null) {
          Get.find<ShellController>().select(item.targetNav!);
        }
      },
      child: Container(
        color: isUnread
            ? AppColors.primary.withValues(alpha: 0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Semantic Category Icon
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 16, color: item.color),
            ),
            const SizedBox(width: 12),
            // Title & Snippet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 6.5,
                          height: 6.5,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (item.message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.message,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.subtitle != null) ...[
                        Expanded(
                          child: Text(
                            item.subtitle!,
                            style: TextStyle(
                              color: palette.textSecondary.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        timeAgo(item.timestamp),
                        style: TextStyle(
                          color: palette.textSecondary.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        Get.find<ShellController>().select(NavId.reports);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        alignment: Alignment.center,
        color: palette.card,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Flexible(
              child: Text(
                'View all in Reports Center',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
