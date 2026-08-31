import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_management_controller.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_management_info_banner.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_management_table.dart';
import 'package:joba_admin/features/admin_management/views/widgets/invite_admin_dialog.dart';

/// Admin Management Screen - Team members, roles, and administrative access control.
class AdminManagementScreen extends GetView<AdminManagementController> {
  const AdminManagementScreen({super.key});

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
              Obx(
                () => PageHeader(
                  title: 'Admin Management',
                  subtitle: 'Team members, roles and access',
                  actions: [
                    if (controller.canManageAdmins)
                      ElevatedButton.icon(
                        onPressed: () => InviteAdminDialog.show(context),
                        icon: const Icon(
                          Icons.person_add_alt_outlined,
                          size: 17,
                        ),
                        label: Responsive.isMobile(context)
                            ? const SizedBox()
                            : const Text('Add Admin'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const AdminManagementTable(),
              const SizedBox(height: 14),
              const AdminManagementInfoBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
