import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';
import 'package:joba_admin/features/avatars/models/avatar_item.dart';

/// Card showing a single preset avatar's image, name, active switch, and delete button.
class AvatarItemCard extends GetView<AvatarsController> {
  final AvatarItem avatar;

  const AvatarItemCard({super.key, required this.avatar});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final a = avatar;
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;
    final bool isSuper = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageAdmins
        : true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Opacity(
              opacity: a.active ? 1 : 0.35,
              child: AvatarCircle(
                name: a.rawName,
                assetPath: a.assetPath.isEmpty ? null : a.assetPath,
                fallbackAssetPath: a.bundledAssetPath,
                bytes: a.pendingBytes,
                size: 74,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              a.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    a.active ? 'Active' : 'Hidden',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: a.active
                          ? AppColors.success
                          : palette.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
                Switch(
                  value: a.active,
                  activeThumbColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: canManage ? (_) => controller.toggleActive(a.id) : null,
                ),
                if (isSuper)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    tooltip: 'Delete',
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    onPressed: () async {
                      final ok = await showConfirmDialog(
                        context,
                        title: 'Delete avatar?',
                        message:
                            'Users currently using this avatar will fall back to the default.',
                        confirmLabel: 'Delete',
                        danger: true,
                      );
                      if (ok) controller.remove(a.id);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
