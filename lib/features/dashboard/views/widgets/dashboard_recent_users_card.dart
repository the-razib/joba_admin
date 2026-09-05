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
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final users = controller.recentUsers;
        if (users.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No users registered yet',
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final u in users)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      AvatarCircle(name: u.name, size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            const SizedBox(height: 2),
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
                      const SizedBox(width: 8),
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
              ),
          ],
        );
      }),
    );
  }
}
