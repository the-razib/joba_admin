import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';
import 'package:joba_admin/features/users/views/user_detail_panel.dart';

/// Side of one square tap target in the row action cluster.
const double _slot = 34;

/// Action buttons cluster (View, Edit, Block/Unblock, Delete) for a user row.
class UserActionButtons extends GetView<UsersController> {
  const UserActionButtons({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    const box = BoxConstraints(minWidth: _slot, minHeight: _slot);
    final u = user;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _slot,
          height: _slot,
          child: IconButton(
            tooltip: 'View',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: box,
            icon: const Icon(
              Icons.visibility_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            onPressed: () => openUserDetail(context, u.uid),
          ),
        ),
        SizedBox(
          width: _slot,
          height: _slot,
          child: IconButton(
            tooltip: 'Edit',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: box,
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.info,
            ),
            onPressed: () => openUserDetail(context, u.uid),
          ),
        ),
        SizedBox(
          width: _slot,
          height: _slot,
          child: PopupMenuButton<String>(
            tooltip: 'More',
            padding: EdgeInsets.zero,
            iconSize: 18,
            onSelected: (v) => _handleMenuAction(context, u, v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'block',
                child: Text(
                  u.status == UserStatus.blocked
                      ? 'Unblock user'
                      : 'Block user',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete user',
                  style: TextStyle(fontSize: 13, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    AppUser u,
    String action,
  ) async {
    if (action == 'block') {
      controller.updateStatus(
        u.uid,
        u.status == UserStatus.blocked ? UserStatus.active : UserStatus.blocked,
      );
      AppToast.success(
        'User updated',
        '${u.name} ${u.status == UserStatus.blocked ? 'unblocked' : 'blocked'} (mock).',
      );
    } else if (action == 'delete') {
      final ok = await showConfirmDialog(
        context,
        title: 'Delete user?',
        message:
            'This permanently removes ${u.name} and their data. This action cannot be undone.',
        confirmLabel: 'Delete',
        danger: true,
      );
      if (ok) {
        controller.remove(u.uid);
        AppToast.success(
          'User deleted',
          '${u.name} removed (mock).',
        );
      }
    }
  }
}
