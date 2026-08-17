import 'package:flutter/material.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/features/push_notifications/views/widgets/notification_preview.dart';

/// Card displaying a single notification campaign entry on compact mobile screens.
class PushCampaignMobileCard extends StatelessWidget {
  final PushNotification notification;
  final VoidCallback onTap;

  const PushCampaignMobileCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = notification;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                      p.channel.icon,
                      color: p.channel.color,
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
                    color: p.channel.color,
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
      ),
    );
  }
}
