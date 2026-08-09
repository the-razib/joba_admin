import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

/// Mobile bottom navigation: 4 primary sections + "More" sheet.
class MobileBottomNav extends GetView<ShellController> {
  const MobileBottomNav({super.key});

  static const _primary = [
    NavId.dashboard,
    NavId.users,
    NavId.articles,
    NavId.avatars,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.current;
      final inPrimary = _primary.contains(current);
      return BottomNavigationBar(
        currentIndex: inPrimary ? _primary.indexOf(current) : 4,
        onTap: (i) {
          if (i == 4) {
            _showMore(context);
          } else {
            controller.select(_primary[i]);
          }
        },
        items: [
          for (final id in _primary)
            BottomNavigationBarItem(
              icon: Icon(navItems
                  .firstWhere((n) => n.id == id)
                  .icon),
              label: navItems.firstWhere((n) => n.id == id).label,
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      );
    });
  }

  void _showMore(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.sidebarBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final item in navItems.where((n) => !_primary.contains(n.id)))
                ActionChip(
                  avatar: Icon(item.icon, size: 16, color: Colors.white),
                  label: Text(
                    item.label,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                  backgroundColor: AppColors.sidebarActive,
                  side: BorderSide.none,
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.select(item.id);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
