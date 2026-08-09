import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/push_notification.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/bilingual_text_field.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/notification_preview.dart';

/// Opens the composer. Pass [existing] to edit a draft.
Future<void> showPushComposer(
  BuildContext context, {
  PushNotification? existing,
}) {
  final draft = ComposerDraft(existing);
  return showDetailPanel(
    context,
    title: existing == null ? 'New Notification' : 'Edit Draft',
    width: 560,
    child: _ComposerBody(draft: draft),
    footer: _ComposerFooter(draft: draft),
  ).whenComplete(draft.dispose);
}

/// Holds composer state outside the widget tree because `showDetailPanel`
/// takes the body and the footer as two separate widgets — they both need to
/// read the same draft, and the footer's Send button depends on validation of
/// what the body is editing.
class ComposerDraft extends ChangeNotifier {
  ComposerDraft(PushNotification? existing)
    : _existing = existing,
      titleBn = TextEditingController(text: existing?.titleBn ?? ''),
      titleEn = TextEditingController(text: existing?.titleEn ?? ''),
      bodyBn = TextEditingController(text: existing?.bodyBn ?? ''),
      bodyEn = TextEditingController(text: existing?.bodyEn ?? ''),
      imageUrl = TextEditingController(text: existing?.imageUrl ?? ''),
      actionLabelBn = TextEditingController(
        text: existing?.actionLabelBn ?? '',
      ),
      actionLabelEn = TextEditingController(
        text: existing?.actionLabelEn ?? '',
      ),
      actionUrl = TextEditingController(text: existing?.actionUrl ?? ''),
      channel = existing?.channel ?? NotificationChannel.push,
      layout = existing?.inAppLayout ?? InAppLayout.modal,
      audience = existing?.audience ?? PushAudience.all {
    for (final c in _controllers) {
      c.addListener(notifyListeners);
    }
  }

  final PushNotification? _existing;

  final TextEditingController titleBn;
  final TextEditingController titleEn;
  final TextEditingController bodyBn;
  final TextEditingController bodyEn;
  final TextEditingController imageUrl;
  final TextEditingController actionLabelBn;
  final TextEditingController actionLabelEn;
  final TextEditingController actionUrl;

  NotificationChannel channel;
  InAppLayout layout;
  PushAudience audience;

  /// Which language the preview renders.
  bool previewBn = true;

  bool get isEdit => _existing != null;

  List<TextEditingController> get _controllers => [
    titleBn,
    titleEn,
    bodyBn,
    bodyEn,
    imageUrl,
    actionLabelBn,
    actionLabelEn,
    actionUrl,
  ];

  void setChannel(NotificationChannel c) {
    channel = c;
    notifyListeners();
  }

  void setLayout(InAppLayout l) {
    layout = l;
    notifyListeners();
  }

  void setAudience(PushAudience a) {
    audience = a;
    notifyListeners();
  }

  void setPreviewBn(bool bn) {
    previewBn = bn;
    notifyListeners();
  }

  String? _orNull(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  /// Live campaign built from the current field values, so validation and the
  /// preview always agree with what will be saved.
  PushNotification campaign() {
    final c = Get.find<PushController>();
    return c.draft(
      id: _existing?.id,
      titleBn: titleBn.text.trim(),
      titleEn: titleEn.text.trim(),
      bodyBn: bodyBn.text.trim(),
      bodyEn: bodyEn.text.trim(),
      audience: audience,
      channel: channel,
      inAppLayout: layout,
      imageUrl: _orNull(imageUrl),
      actionLabelBn: _orNull(actionLabelBn),
      actionLabelEn: _orNull(actionLabelEn),
      actionUrl: _orNull(actionUrl),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(notifyListeners);
      c.dispose();
    }
    super.dispose();
  }
}

class _ComposerBody extends StatelessWidget {
  const _ComposerBody({required this.draft});

  final ComposerDraft draft;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final campaign = draft.campaign();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Delivery channel'),
              const SizedBox(height: 6),
              _ChannelPicker(draft: draft),
              const SizedBox(height: 8),
              Text(
                draft.channel.blurb,
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
              if (draft.channel.hasInApp) ...[
                const SizedBox(height: 18),
                const _Label('In-app layout'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final l in InAppLayout.values)
                      ChoiceChip(
                        selected: draft.layout == l,
                        label: Text(
                          l.label,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onSelected: (_) => draft.setLayout(l),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              BilingualField(
                label: 'Title *',
                bnController: draft.titleBn,
                enController: draft.titleEn,
                hintEn: 'Notification title',
              ),
              const SizedBox(height: 16),
              BilingualField(
                label: draft.layout.requiresImage && !draft.channel.hasPush
                    ? 'Body'
                    : 'Body *',
                bnController: draft.bodyBn,
                enController: draft.bodyEn,
                maxLines: 3,
                hintEn: 'Notification body…',
              ),
              const SizedBox(height: 18),
              _ImageField(draft: draft),
              const SizedBox(height: 18),
              _ActionField(draft: draft),
              const SizedBox(height: 18),
              const _Label('Audience'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in PushAudience.values)
                    ChoiceChip(
                      selected: draft.audience == a,
                      label: Text(a.name, style: const TextStyle(fontSize: 12)),
                      onSelected: (_) => draft.setAudience(a),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              _PreviewSection(draft: draft, campaign: campaign),
              if (campaign.issues.isNotEmpty) ...[
                const SizedBox(height: 18),
                _NoticeBox(
                  color: AppColors.danger,
                  icon: Icons.error_outline,
                  title: 'Fix before sending',
                  lines: campaign.issues,
                ),
              ],
              if (campaign.warnings.isNotEmpty) ...[
                const SizedBox(height: 12),
                _NoticeBox(
                  color: AppColors.warning,
                  icon: Icons.info_outline,
                  title: 'Worth checking',
                  lines: campaign.warnings,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChannelPicker extends StatelessWidget {
  const _ChannelPicker({required this.draft});

  final ComposerDraft draft;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<NotificationChannel>(
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: [
        for (final c in NotificationChannel.values)
          ButtonSegment(
            value: c,
            label: Text(c.label, style: const TextStyle(fontSize: 12)),
          ),
      ],
      selected: {draft.channel},
      onSelectionChanged: (s) => draft.setChannel(s.first),
    );
  }
}

class _ImageField extends StatelessWidget {
  const _ImageField({required this.draft});

  final ComposerDraft draft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(draft.layout.requiresImage ? 'Image *' : 'Image (optional)'),
        const SizedBox(height: 6),
        TextField(
          controller: draft.imageUrl,
          style: TextStyle(color: context.palette.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'https://…',
            prefixIcon: Icon(Icons.image_outlined, size: 18),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          // Phase 3 replaces this with an upload that writes to Cloud Storage
          // and fills in the download URL.
          'Recommended $kRecommendedImageNote.',
          style: TextStyle(
            color: context.palette.textSecondary,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ActionField extends StatelessWidget {
  const _ActionField({required this.draft});

  final ComposerDraft draft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualField(
          label: 'Action button (optional)',
          bnController: draft.actionLabelBn,
          enController: draft.actionLabelEn,
          hintBn: 'বাটনের লেখা…',
          hintEn: 'Button label…',
        ),
        const SizedBox(height: 8),
        TextField(
          controller: draft.actionUrl,
          style: TextStyle(color: context.palette.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'joba://premium or https://…',
            prefixIcon: Icon(Icons.link, size: 18),
          ),
        ),
      ],
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.draft, required this.campaign});

  final ComposerDraft draft;
  final PushNotification campaign;

  @override
  Widget build(BuildContext context) {
    final bn = draft.previewBn;
    final title = bn ? campaign.titleBn : campaign.titleEn;
    final body = bn ? campaign.bodyBn : campaign.bodyEn;
    final action = bn ? campaign.actionLabelBn : campaign.actionLabelEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _Label('Preview'),
            const Spacer(),
            for (final isBn in [true, false])
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChoiceChip(
                  selected: bn == isBn,
                  label: Text(
                    isBn ? 'বাংলা' : 'English',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  onSelected: (_) => draft.setPreviewBn(isBn),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (campaign.channel.hasPush) ...[
          _PreviewCaption('Notification tray', 'Locked phone, app closed'),
          const SizedBox(height: 6),
          PushPreview(
            title: title,
            body: body,
            bengali: bn,
            imageUrl: campaign.imageUrl,
          ),
        ],
        if (campaign.channel.hasInApp) ...[
          if (campaign.channel.hasPush) const SizedBox(height: 14),
          _PreviewCaption(
            '${campaign.inAppLayout.label} dialog',
            'Shown on next app open',
          ),
          const SizedBox(height: 6),
          InAppPreview(
            title: title,
            body: body,
            bengali: bn,
            layout: campaign.inAppLayout,
            imageUrl: campaign.imageUrl,
            actionLabel: action,
          ),
        ],
      ],
    );
  }
}

class _PreviewCaption extends StatelessWidget {
  const _PreviewCaption(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '· $subtitle',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({
    required this.color,
    required this.icon,
    required this.title,
    required this.lines,
  });

  final Color color;
  final IconData icon;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '· $l',
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ComposerFooter extends StatelessWidget {
  const _ComposerFooter({required this.draft});

  final ComposerDraft draft;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final campaign = draft.campaign();
        final controller = Get.find<PushController>();

        Future<void> commit({required bool send}) async {
          await controller.save(campaign, send: send);
          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          Get.snackbar(
            send ? 'Notification sent' : 'Draft saved',
            send
                ? 'Queued to ${campaign.channel.label} (mock).'
                : 'Draft stored for later (mock).',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => commit(send: false),
                child: const Text('Save Draft'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                // Blocked rather than hidden, so the reason stays visible in
                // the issues box above.
                onPressed: campaign.canSend ? () => commit(send: true) : null,
                icon: const Icon(Icons.send, size: 15),
                label: const Text('Send Now'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.palette.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
