import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/widgets/app_logo.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

/// Proper black navigation sidebar with crisp high-contrast typography and subtle borders.
/// `rail` renders the 76px icon rail used on tablet / collapsed desktop.
class Sidebar extends GetView<ShellController> {
  const Sidebar({super.key, this.rail = false});

  final bool rail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rail ? 76 : 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
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
      padding: rail
          ? const EdgeInsets.fromLTRB(0, 22, 0, 10)
          : const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(
        mainAxisAlignment: rail
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          const AppLogo(size: 40),
          if (!rail) ...[
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Joba',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Period Tracker',
                    style: TextStyle(
                      color: AppColors.sidebarText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
              padding: const EdgeInsets.fromLTRB(10, 16, 8, 8),
              child: Text(
                'ADMINISTRATION',
                style: TextStyle(
                  color: AppColors.sidebarText.withValues(alpha: 0.65),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
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
      borderRadius: BorderRadius.circular(10),
      onTap: () => controller.select(item.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: rail ? 0 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: AppColors.sidebarBorder, width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: rail
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              item.icon,
              size: 19,
              color: selected ? AppColors.primary : AppColors.sidebarText,
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
              if (selected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.sidebarActive,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.sidebarBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Version',
                  style: TextStyle(
                    color: AppColors.sidebarText.withValues(alpha: 0.8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              'v1.0.0',
              style: TextStyle(
                color: AppColors.sidebarText.withValues(alpha: 0.8),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
