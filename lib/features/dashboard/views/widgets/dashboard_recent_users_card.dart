import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

/// Card displaying the list of recently registered/active users.
class DashboardRecentUsersCard extends GetView<DashboardController> {
  const DashboardRecentUsersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();

    return SectionCard(
      title: 'Recent Users',
      action: 'View All',
      onAction: () => shell.select(NavId.users),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          for (final u in controller.recentUsers)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  AvatarCircle(name: u.name, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          u.email,
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
                  Text(
                    timeAgo(u.lastActive),
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  userPlanBadge(u.plan),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
