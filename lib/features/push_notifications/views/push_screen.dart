import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/push_notification.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/notification_preview.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/push_composer.dart';

Color channelColor(NotificationChannel c) => switch (c) {
  NotificationChannel.push => AppColors.primary,
  NotificationChannel.inApp => AppColors.purple,
  NotificationChannel.both => AppColors.accent,
};

IconData channelIcon(NotificationChannel c) => switch (c) {
  NotificationChannel.push => Icons.notifications_active_outlined,
  NotificationChannel.inApp => Icons.chat_bubble_outline,
  NotificationChannel.both => Icons.layers_outlined,
};

class PushScreen extends GetView<PushController> {
  const PushScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(mobile ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Push Notifications',
                  subtitle:
                      'Push and in-app dialogs, composed in বাংলা and '
                      'English',
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () => showPushComposer(context),
                      icon: const Icon(Icons.add, size: 17),
                      label: mobile
                          ? const SizedBox()
                          : const Text('New Notification'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _StatGrid(),
                const SizedBox(height: 16),
                const _ChannelFilter(),
                const SizedBox(height: 12),
                const _CampaignTable(),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _StatGrid extends GetView<PushController> {
  const _StatGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = <(IconData, String, String, double?, String, Color)>[
        (
          Icons.send_outlined,
          'Total Sent',
          '${controller.sentCount}',
          8.1,
          'vs last 7 days',
          AppColors.primary,
        ),
        (
          Icons.mark_chat_read_outlined,
          'Delivered',
          compactNumber(controller.totalDelivered),
          5.4,
          'vs last 7 days',
          AppColors.info,
        ),
        (
          Icons.touch_app_outlined,
          'Opened',
          compactNumber(controller.totalOpened),
          11.2,
          'vs last 7 days',
          AppColors.accent,
        ),
        (
          Icons.show_chart,
          'Open Rate',
          '${controller.openRate.toStringAsFixed(1)}%',
          2.3,
          'vs last 7 days',
          AppColors.success,
        ),
      ];
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.pick(
            context,
            mobile: 2,
            tablet: 4,
            desktop: 4,
          ),
          mainAxisExtent: 104,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => StatCard(
          icon: stats[i].$1,
          label: stats[i].$2,
          value: stats[i].$3,
          deltaPercent: stats[i].$4,
          compareLabel: stats[i].$5,
          iconColor: stats[i].$6,
        ),
      );
    });
  }
}

class _ChannelFilter extends GetView<PushController> {
  const _ChannelFilter();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.channelFilter.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            selected: active == null,
            label: const Text('All', style: TextStyle(fontSize: 12)),
            onSelected: (_) => controller.setChannelFilter(null),
          ),
          for (final c in NotificationChannel.values)
            ChoiceChip(
              selected: active == c,
              avatar: Icon(
                channelIcon(c),
                size: 14,
                color: active == c ? Colors.white : channelColor(c),
              ),
              label: Text(c.label, style: const TextStyle(fontSize: 12)),
              onSelected: (_) => controller.setChannelFilter(c),
            ),
        ],
      );
    });
  }
}

class _CampaignTable extends GetView<PushController> {
  const _CampaignTable();

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
          onRowTap: (p) => _openDetail(context, p.id),
          cardBuilder: _card,
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
                color: channelColor(p.channel),
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
              // Always three icon buttons: view, edit-or-resend, delete.
              // Each is 40 wide once the tap target is padded out.
              width: 124,
              align: Alignment.centerRight,
              build: (context, p) => _rowActions(context, p),
            ),
          ],
        ),
      );
    });
  }

  Widget _rowActions(BuildContext context, PushNotification p) {
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
          onPressed: () => _openDetail(context, p.id),
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
              await Get.find<PushController>().resend(p.id);
              Get.snackbar(
                'Resent',
                'Notification queued again (mock).',
                snackPosition: SnackPosition.BOTTOM,
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
            if (ok) Get.find<PushController>().remove(p.id);
          },
        ),
      ],
    );
  }

  Widget _card(BuildContext context, PushNotification p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.hasImage)
                  PreviewImage(
                    url: p.imageUrl!,
                    height: 40,
                    width: 40,
                    radius: 8,
                  )
                else
                  Icon(
                    channelIcon(p.channel),
                    color: channelColor(p.channel),
                    size: 20,
                  ),
                const SizedBox(width: 10),
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                p.status == PushStatus.sent
                    ? const PillBadge(label: 'Sent', color: AppColors.success)
                    : const PillBadge(label: 'Draft', color: AppColors.warning),
                PillBadge(
                  label: p.channel.label,
                  color: channelColor(p.channel),
                ),
                PillBadge(
                  label: p.audience.name.toUpperCase(),
                  color: AppColors.info,
                ),
                if (p.sentAt != null)
                  Text(
                    formatDate(p.sentAt!),
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String id) {
    showDetailPanel(
      context,
      title: 'Notification Details',
      width: 480,
      child: _DetailBody(id: id),
      footer: _DetailFooter(id: id),
    );
  }
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({required this.id});

  final String id;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
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
  ) => Expanded(
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

class _DetailFooter extends GetView<PushController> {
  const _DetailFooter({required this.id});

  final String id;

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
