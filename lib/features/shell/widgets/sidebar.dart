import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/widgets/app_logo.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

/// Dark-green navigation sidebar. `rail` renders the 76px icon rail
/// used on tablet / collapsed desktop.
class Sidebar extends GetView<ShellController> {
  const Sidebar({super.key, this.rail = false});

  final bool rail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rail ? 76 : 260,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          _header(),
          const SizedBox(height: 8),
          Expanded(child: _navList()),
          if (!rail) _footer(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      // The 76px rail cannot fit the 42px mark inside the 20px gutters.
      padding: rail
          ? const EdgeInsets.fromLTRB(0, 22, 0, 10)
          : const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        mainAxisAlignment: rail
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          const AppLogo(size: 42),
          if (!rail) ...[
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Joba',
                  style: TextStyle(
                    color: Color(0xFF2FD079),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Period Tracker',
                  style: TextStyle(color: AppColors.sidebarText, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _navList() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      children: [
        for (final item in navItems) ...[
          if (!rail &&
              item.administration &&
              item == navItems.firstWhere((n) => n.administration))
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
              child: Text(
                'ADMINISTRATION',
                style: TextStyle(
                  color: AppColors.sidebarText.withValues(alpha: 0.7),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          Obx(() => _tile(item)),
        ],
      ],
    );
  }

  Widget _tile(NavItem item) {
    final selected = controller.current == item.id;
    final tile = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => controller.select(item.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: rail ? 0 : 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: rail
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              item.icon,
              size: 20,
              color: selected ? Colors.white : AppColors.sidebarText,
            ),
            if (!rail) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.sidebarText,
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return rail ? Tooltip(message: item.label, child: tile) : tile;
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sidebarActive,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You're Pro! 🎉",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thank you for being an amazing admin.',
              style: TextStyle(
                color: AppColors.sidebarText,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFF2FD079),
                    size: 19,
                  ),
                ),
                const Spacer(),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: AppColors.sidebarText.withValues(alpha: 0.7),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
