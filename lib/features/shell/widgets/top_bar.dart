import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_profile_dialog.dart';
import 'package:joba_admin/features/notifications/controllers/admin_notifications_controller.dart';
import 'package:joba_admin/features/notifications/views/widgets/admin_notifications_popover.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';
import 'package:joba_admin/routes/app_routes.dart';

class TopBar extends GetView<ShellController> implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final mobile = Responsive.isMobile(context);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (mobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () =>
                    Scaffold.of(context).openDrawer(),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Toggle sidebar',
              onPressed: controller.toggleSidebar,
            ),
          const SizedBox(width: 4),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.currentLabel,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!mobile)
                  Text(
                    'Dashboard  ›  ${controller.currentLabel}',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),

          Obx(
            () => IconButton(
              tooltip: 'Toggle theme',
              icon: Icon(
                Get.find<ThemeService>().isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () => Get.find<ThemeService>().toggle(),
            ),
          ),
          Obx(() {
            final unread = Get.isRegistered<AdminNotificationsController>()
                ? Get.find<AdminNotificationsController>().unreadCount
                : 0;
            return IconButton(
              tooltip: 'Notifications',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none, size: 22),
                  if (unread > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => AdminNotificationsPopover.show(context),
            );
          }),
          const SizedBox(width: 6),
          Obx(() {
            final admin = Get.find<AuthService>().user.value;
            if (admin == null) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              offset: const Offset(0, 48),
              tooltip: 'Admin Profile & Menu',
              onSelected: (v) {
                if (v == 'profile') {
                  AdminProfileDialog.show(context);
                } else if (v == 'logout') {
                  Get.find<AuthService>().logout();
                  Get.offAllNamed(AppRoutes.login);
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarCircle(
                      name: admin.name,
                      url: admin.photoUrl,
                      size: 38,
                    ),
                    if (!mobile) ...[
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            admin.name,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            admin.role.label,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ],
                ),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(Icons.person_outline, size: 18),
                      SizedBox(width: 8),
                      Text('My profile', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 18, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text('Log out',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            );
          }),

        ],
      ),
    );
  }
}
