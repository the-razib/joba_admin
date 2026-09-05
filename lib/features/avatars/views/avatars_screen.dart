import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';
import 'package:joba_admin/features/avatars/views/widgets/add_category_dialog.dart';
import 'package:joba_admin/features/avatars/views/widgets/avatar_category_chips.dart';
import 'package:joba_admin/features/avatars/views/widgets/avatar_grid_view.dart';
import 'package:joba_admin/features/avatars/views/widgets/upload_avatars_flow.dart';

/// Avatar Management Screen - Manage and upload preset profile avatars.
class AvatarsScreen extends GetView<AvatarsController> {
  const AvatarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final bool canManage = Get.isRegistered<AuthService>()
          ? Get.find<AuthService>().canManageContent
          : true;

      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Avatar Management',
                  subtitle: "Preset avatars shown in the app's profile picker",
                  actions: canManage
                      ? [
                          OutlinedButton.icon(
                            onPressed: () => AddCategoryDialog.show(context),
                            icon: const Icon(
                              Icons.create_new_folder_outlined,
                              size: 17,
                            ),
                            label: Responsive.isMobile(context)
                                ? const SizedBox()
                                : const Text('Add Category'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => uploadAvatarsFlow(context),
                            icon: const Icon(
                              Icons.upload_file_outlined,
                              size: 17,
                            ),
                            label: Responsive.isMobile(context)
                                ? const SizedBox()
                                : const Text('Upload Avatars'),
                          ),
                        ]
                      : const [],
                ),
                const SizedBox(height: 14),
                const AvatarCategoryChips(),
                const SizedBox(height: 16),
                const AvatarGridView(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
