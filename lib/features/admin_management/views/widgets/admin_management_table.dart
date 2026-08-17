import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/admin_management/models/admin_profile.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_management_controller.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_management_mobile_card.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_role_badge.dart';

/// Card containing the data table for managing administrator accounts and roles.
class AdminManagementTable extends GetView<AdminManagementController> {
  const AdminManagementTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canManage = controller.canManageAdmins;

      return Card(
        child: AdaptiveDataTable<AdminProfile>(
          rows: controller.admins,
          cardBuilder: (context, a) => AdminManagementMobileCard(admin: a),
          columns: [
            AdaptiveColumn<AdminProfile>(
              label: 'Admin',
              flex: 3,
              build: (context, a) => Row(
                children: [
                  AvatarCircle(name: a.name, size: 38),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          a.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
            ),
            AdaptiveColumn<AdminProfile>(
              label: 'Role',
              flex: 2,
              build: (context, a) => canManage
                  ? PopupMenuButton<AdminRole>(
                      onSelected: (r) => controller.setRole(a.uid, r),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AdminRoleBadge(role: a.role),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                          ),
                        ],
                      ),
                      itemBuilder: (_) => [
                        for (final r in AdminRole.values)
                          PopupMenuItem(
                            value: r,
                            child: Text(
                              r.label,
                              style: const TextStyle(fontSize: 13),
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
              width: 84,
              align: Alignment.centerRight,
              build: (context, a) => canManage
                  ? TextButton(
                      onPressed: () => controller.toggleActive(a.uid),
                      child: Text(
                        a.active ? 'Disable' : 'Enable',
                        style: TextStyle(
                          fontSize: 12,
                          color: a.active
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      );
    });
  }
}
