import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
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
    final admin = Get.find<AuthService>().user.value;

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
          if (Responsive.isDesktop(context))
            SizedBox(
              width: 260,
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search anything...',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 18),
                ),
              ),
            ),
          if (Responsive.isDesktop(context)) const SizedBox(width: 8),
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
          IconButton(
            tooltip: 'Notifications',
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, size: 22),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '6',
                      style: TextStyle(color: Colors.white, fontSize: 8.5),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => AppToast.info(
              'Notifications',
              '6 pending items — full inbox ships in Phase 2.',
            ),
          ),
          const SizedBox(width: 6),
          if (admin != null)
            PopupMenuButton<String>(
              offset: const Offset(0, 48),
              onSelected: (v) {
                if (v == 'logout') {
                  Get.find<AuthService>().logout();
                  Get.offAllNamed(AppRoutes.login);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarCircle(name: admin.name, size: 38),
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
            ),
        ],
      ),
    );
  }
}
