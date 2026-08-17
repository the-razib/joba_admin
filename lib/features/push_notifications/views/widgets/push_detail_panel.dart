import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/notification_preview.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_composer.dart';

/// Helper function to open the full notification campaign detail panel.
void openPushDetailPanel(BuildContext context, String notificationId) {
  showDetailPanel(
    context,
    title: 'Notification Details',
    width: 480,
    child: PushDetailBody(id: notificationId),
    footer: PushDetailFooter(id: notificationId),
  );
}

/// The body content of the notification detail drawer.
class PushDetailBody extends StatefulWidget {
  final String id;

  const PushDetailBody({super.key, required this.id});

  @override
  State<PushDetailBody> createState() => _PushDetailBodyState();
}

class _PushDetailBodyState extends State<PushDetailBody> {
  bool _bn = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PushController>();
    return Obx(() {
      final p = controller.all.firstWhereOrNull((e) => e.id == widget.id);
      if (p == null) return const SizedBox();
      final palette = context.palette;
      final title = _bn ? p.titleBn : p.titleEn;
      final body = _bn ? p.bodyBn : p.bodyEn;
      final action = _bn ? p.actionLabelBn : p.actionLabelEn;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (final bn in [true, false])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: _bn == bn,
                      label: Text(
                        bn ? 'বাংলা' : 'English',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onSelected: (_) => setState(() => _bn = bn),
                    ),
                  ),
                const Spacer(),
                p.status == PushStatus.sent
                    ? const PillBadge(label: 'Sent', color: AppColors.success)
                    : const PillBadge(label: 'Draft', color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 16),
            if (p.channel.hasPush) ...[
              PushPreview(
                title: title,
                body: body,
                bengali: _bn,
                imageUrl: p.imageUrl,
              ),
              if (p.channel.hasInApp) const SizedBox(height: 12),
            ],
            if (p.channel.hasInApp)
              InAppPreview(
                title: title,
                body: body,
                bengali: _bn,
                layout: p.inAppLayout,
                imageUrl: p.imageUrl,
                actionLabel: action,
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                _statTile(
                  context,
                  'Delivered',
                  compactNumber(p.delivered),
                  AppColors.info,
                ),
                const SizedBox(width: 10),
                _statTile(
                  context,
                  'Opened',
                  compactNumber(p.opened),
                  AppColors.accent,
                ),
                const SizedBox(width: 10),
                _statTile(
                  context,
                  'Open Rate',
                  '${p.openRate.toStringAsFixed(1)}%',
                  AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final row in [
              ('Channel', p.channel.label),
              if (p.channel.hasInApp) ('In-app layout', p.inAppLayout.label),
              ('Audience', p.audience.name),
              ('Image', p.hasImage ? p.imageUrl! : '—'),
              ('Action', p.hasAction ? (p.actionUrl ?? '—') : '—'),
              ('Notification ID', p.id),
              ('Sent at', p.sentAt == null ? '—' : formatDateTime(p.sentAt!)),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        row.$1,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _statTile(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      );
}

/// The footer actions of the notification detail drawer.
class PushDetailFooter extends GetView<PushController> {
  final String id;

  const PushDetailFooter({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.all.firstWhereOrNull((e) => e.id == id);
      if (p == null) return const SizedBox();

      if (p.status == PushStatus.draft) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  showPushComposer(context, existing: p);
                },
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const Text('Edit Draft'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: p.canSend
                    ? () async {
                        await controller.sendDraft(id);
                        Get.snackbar(
                          'Sent',
                          'Notification sent (mock).',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      }
                    : null,
                icon: const Icon(Icons.send, size: 15),
                label: const Text('Send Now'),
              ),
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                await controller.resend(id);
                Get.snackbar(
                  'Resent',
                  'Notification queued again (mock).',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: const Icon(Icons.replay_outlined, size: 15),
              label: const Text('Resend'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: 'Delete notification?',
                  message: '"${p.titleEn}" will be removed.',
                  confirmLabel: 'Delete',
                  danger: true,
                );
                if (ok) {
                  controller.remove(id);
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                }
              },
              icon: const Icon(Icons.delete_outline, size: 15),
              label: const Text('Delete'),
            ),
          ),
        ],
      );
    });
  }
}
