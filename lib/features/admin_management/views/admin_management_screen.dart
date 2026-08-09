import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/admin_profile.dart';
import 'package:joba_admin/core/models/admin_user.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_management_controller.dart';

class AdminManagementScreen extends GetView<AdminManagementController> {
  const AdminManagementScreen({super.key});

  bool get _canManage =>
      Get.find<AuthService>().user.value?.role == AdminRole.superAdmin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Admin Management',
                subtitle: 'Team members, roles and access',
                actions: [
                  if (_canManage)
                    ElevatedButton.icon(
                      onPressed: () => _inviteDialog(context),
                      icon: const Icon(Icons.person_add_alt_outlined, size: 17),
                      label: Responsive.isMobile(context)
                          ? const SizedBox()
                          : const Text('Invite Admin'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(
                () => Card(
                  child: AdaptiveDataTable<AdminProfile>(
                    rows: controller.admins,
                    cardBuilder: (context, a) => Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AvatarCircle(name: a.name, size: 40),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.name,
                                      style: TextStyle(
                                        color: context.palette.textPrimary,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      a.email,
                                      style: TextStyle(
                                        color: context.palette.textSecondary,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _roleBadge(a.role),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last active ${timeAgo(a.lastActive)} • ${a.active ? 'Active' : 'Disabled'}',
                            style: TextStyle(
                              color: context.palette.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        build: (context, a) => _canManage
                            ? PopupMenuButton<AdminRole>(
                                onSelected: (r) => controller.setRole(a.uid, r),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _roleBadge(a.role),
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
                            : _roleBadge(a.role),
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
                        build: (context, a) => _canManage
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
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 17,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Phase 3 enforces roles with Firebase custom claims: Super Admin (all), Editor (content), Viewer (read-only).',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PillBadge _roleBadge(AdminRole r) => switch (r) {
    AdminRole.superAdmin => const PillBadge(
      label: 'Super Admin',
      color: AppColors.primary,
      icon: Icons.shield,
    ),
    AdminRole.editor => const PillBadge(label: 'Editor', color: AppColors.info),
    AdminRole.viewer => const PillBadge(
      label: 'Viewer',
      color: AppColors.warning,
    ),
  };

  void _inviteDialog(BuildContext context) {
    final name = TextEditingController();
    final email = TextEditingController();
    AdminRole role = AdminRole.editor;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Admin',
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(hintText: 'Full name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in AdminRole.values)
                        ChoiceChip(
                          selected: role == r,
                          label: Text(
                            r.label,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onSelected: (_) => setState(() => role = r),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (name.text.trim().isEmpty ||
                              !email.text.contains('@')) {
                            return;
                          }
                          controller.invite(
                            name: name.text.trim(),
                            email: email.text.trim(),
                            role: role,
                          );
                          Navigator.of(context).pop();
                          Get.snackbar(
                            'Invite sent',
                            '${email.text.trim()} invited as ${role.label} (mock).',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: const Text('Send Invite'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
