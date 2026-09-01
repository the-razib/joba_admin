import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/pagination_bar.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_management_controller.dart';
import 'package:joba_admin/features/admin_management/models/admin_profile.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_management_mobile_card.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_role_badge.dart';

/// Card containing the paginated data table for managing administrator accounts and roles.
class AdminManagementTable extends GetView<AdminManagementController> {
  const AdminManagementTable({super.key});

  Future<void> _confirmSetRole(
    BuildContext context,
    AdminProfile a,
    AdminRole newRole,
  ) async {
    if (a.role == newRole) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Admin Role'),
        content: Text(
          'Change ${a.name}\'s role from ${a.role.label} to ${newRole.label}?\n\n'
          'The new permissions will apply on their next login or token refresh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.setRole(a.uid, newRole);
    }
  }

  Future<void> _confirmToggleActive(
    BuildContext context,
    AdminProfile a,
  ) async {
    if (a.uid == controller.currentUid && a.active) {
      AppToast.error('Action Blocked', 'You cannot deactivate your own account.');
      return;
    }

    final action = a.active ? 'Disable' : 'Enable';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action Administrator'),
        content: Text(
          '$action ${a.name}\'s admin access?\n\n'
          '${a.active ? 'Disabled administrators cannot access the panel.' : 'Enabled administrators can sign in immediately.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: a.active
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.danger)
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.toggleActive(a.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canManage = controller.canManageAdmins;
      bool isSelf(String uid) => controller.currentUid == uid;

      if (controller.isLoading.value && controller.admins.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      return Card(
        child: Column(
          children: [
            AdaptiveDataTable<AdminProfile>(
              rows: controller.paginated,
              cardBuilder: (context, a) => AdminManagementMobileCard(admin: a),
              columns: [
                AdaptiveColumn<AdminProfile>(
                  label: 'Admin',
                  flex: 3,
                  build: (context, a) => Row(
                    children: [
                      AvatarCircle(name: a.name, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    a.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.palette.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isSelf(a.uid)) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'You',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              a.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.palette.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AdminProfile>(
                  label: 'Role',
                  flex: 2,
                  build: (context, a) => canManage && !isSelf(a.uid)
                      ? PopupMenuButton<AdminRole>(
                          tooltip: 'Change role',
                          initialValue: a.role,
                          onSelected: (newRole) => _confirmSetRole(context, a, newRole),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AdminRoleBadge(role: a.role),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: context.palette.textSecondary,
                              ),
                            ],
                          ),
                          itemBuilder: (ctx) => [
                            for (final r in AdminRole.values)
                              PopupMenuItem(
                                value: r,
                                child: Row(
                                  children: [
                                    AdminRoleBadge(role: r),
                                    const SizedBox(width: 8),
                                    Text(
                                      r.label,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                      : AdminRoleBadge(role: a.role),
                ),
                AdaptiveColumn<AdminProfile>(
                  label: 'Status',
                  flex: 2,
                  build: (context, a) => a.active
                      ? const PillBadge(
                          label: 'Active',
                          color: AppColors.success,
                        )
                      : const PillBadge(
                          label: 'Disabled',
                          color: AppColors.danger,
                        ),
                ),
                AdaptiveColumn<AdminProfile>(
                  label: 'Last Active',
                  flex: 2,
                  tabletHidden: true,
                  build: (context, a) => Text(
                    timeAgo(a.lastActive),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                AdaptiveColumn<AdminProfile>(
                  label: '',
                  width: 90,
                  align: Alignment.centerRight,
                  build: (context, a) {
                    if (!canManage) return const SizedBox();
                    final isCurrent = isSelf(a.uid);

                    if (isCurrent && a.active) {
                      return Tooltip(
                        message: 'Cannot deactivate yourself',
                        child: TextButton(
                          onPressed: null,
                          child: Text(
                            'Disable',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.palette.textSecondary.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      );
                    }

                    return TextButton(
                      onPressed: () => _confirmToggleActive(context, a),
                      child: Text(
                        a.active ? 'Disable' : 'Enable',
                        style: TextStyle(
                          fontSize: 12,
                          color: a.active
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (controller.admins.isNotEmpty)
              PaginationBar(
                page: controller.page.value,
                totalItems: controller.admins.length,
                pageSize: controller.pageSize.value,
                onPageChanged: (p) => controller.page.value = p,
                onPageSizeChanged: (s) {
                  controller.pageSize.value = s;
                  controller.page.value = 1;
                },
              ),
          ],
        ),
      );
    });
  }
}
