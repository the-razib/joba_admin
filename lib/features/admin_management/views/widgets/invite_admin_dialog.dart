import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_management_controller.dart';
import 'package:joba_admin/core/utils/app_toast.dart';

/// Modal dialog for inviting a new administrator and assigning initial role.
class InviteAdminDialog extends StatefulWidget {
  const InviteAdminDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const InviteAdminDialog(),
    );
  }

  @override
  State<InviteAdminDialog> createState() => _InviteAdminDialogState();
}

class _InviteAdminDialogState extends State<InviteAdminDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  AdminRole _role = AdminRole.editor;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminManagementController>();

    return Dialog(
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
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Full name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in AdminRole.values)
                    ChoiceChip(
                      selected: _role == r,
                      label: Text(
                        r.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onSelected: (_) => setState(() => _role = r),
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
                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      if (name.isEmpty || !email.contains('@')) return;

                      controller.invite(
                        name: name,
                        email: email,
                        role: _role,
                      );
                      Navigator.of(context).pop();
                      AppToast.success(
                        'Invite sent',
                        '$email invited as ${_role.label} (mock).',
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
    );
  }
}
