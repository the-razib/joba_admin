import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/notification_preview.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_campaign_mobile_card.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_composer.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_detail_panel.dart';

/// Card containing the adaptive table and empty state for notification campaigns.
class PushCampaignTable extends GetView<PushController> {
  const PushCampaignTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.visible;
      if (list.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 44),
            child: Column(
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 34,
                  color: context.palette.textSecondary,
                ),
                const SizedBox(height: 10),
                Text(
                  'No notifications on this channel yet.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Card(
        child: AdaptiveDataTable<PushNotification>(
          rows: list,
          onRowTap: (p) => openPushDetailPanel(context, p.id),
          cardBuilder: (context, p) => PushCampaignMobileCard(
            notification: p,
            onTap: () => openPushDetailPanel(context, p.id),
          ),
          columns: [
            AdaptiveColumn<PushNotification>(
              label: 'Notification',
              flex: 3,
              build: (context, p) => Row(
                children: [
                  if (p.hasImage) ...[
                    PreviewImage(
                      url: p.imageUrl!,
                      height: 34,
                      width: 34,
                      radius: 7,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.titleEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          p.titleBn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bengali(
                            context,
                            fontSize: 11.5,
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AdaptiveColumn<PushNotification>(
              label: 'Channel',
              flex: 3,
              build: (context, p) => PillBadge(
                label: p.channel.label,
                color: p.channel.color,
              ),
            ),
            AdaptiveColumn<PushNotification>(
              label: 'Audience',
              flex: 3,
              tabletHidden: true,
              build: (context, p) => PillBadge(
                label: p.audience.name.toUpperCase(),
                color: AppColors.info,
              ),
            ),
            AdaptiveColumn<PushNotification>(
              label: 'Status',
              flex: 2,
              build: (context, p) => p.status == PushStatus.sent
                  ? const PillBadge(label: 'Sent', color: AppColors.success)
                  : const PillBadge(label: 'Draft', color: AppColors.warning),
            ),
            AdaptiveColumn<PushNotification>(
              label: 'Sent At',
              flex: 3,
              tabletHidden: true,
              build: (context, p) => Text(
                p.sentAt == null ? '—' : formatDate(p.sentAt!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            AdaptiveColumn<PushNotification>(
              label: 'Open Rate',
              flex: 2,
              tabletHidden: true,
              build: (context, p) => Text(
                p.status == PushStatus.sent
                    ? '${p.openRate.toStringAsFixed(1)}%'
                    : '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 12.5,
                ),
              ),
            ),
            AdaptiveColumn<PushNotification>(
              label: 'Actions',
              width: 124,
              align: Alignment.centerRight,
              build: (context, p) => _RowActions(notification: p),
            ),
          ],
        ),
      );
    });
  }
}

class _RowActions extends GetView<PushController> {
  final PushNotification notification;

  const _RowActions({required this.notification});

  @override
  Widget build(BuildContext context) {
    final p = notification;
    const box = BoxConstraints(minWidth: 32, minHeight: 32);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'View',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: box,
          icon: const Icon(
            Icons.visibility_outlined,
            size: 17,
            color: AppColors.primary,
          ),
          onPressed: () => openPushDetailPanel(context, p.id),
        ),
        if (p.status == PushStatus.draft)
          IconButton(
            tooltip: 'Edit draft',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: box,
            icon: const Icon(
              Icons.edit_outlined,
              size: 17,
              color: AppColors.info,
            ),
            onPressed: () => showPushComposer(context, existing: p),
          ),
        if (p.status == PushStatus.sent)
          IconButton(
            tooltip: 'Resend',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: box,
            icon: const Icon(
              Icons.replay_outlined,
              size: 17,
              color: AppColors.warning,
            ),
            onPressed: () async {
              await controller.resend(p.id);
              AppToast.success(
                'Resent',
                'Notification queued again (mock).',
              );
            },
          ),
        IconButton(
          tooltip: 'Delete',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: box,
          icon: const Icon(
            Icons.delete_outline,
            size: 17,
            color: AppColors.danger,
          ),
          onPressed: () async {
            final ok = await showConfirmDialog(
              context,
              title: 'Delete notification?',
              message: '"${p.titleEn}" will be removed.',
              confirmLabel: 'Delete',
              danger: true,
            );
            if (ok) controller.remove(p.id);
          },
        ),
      ],
    );
  }
}
