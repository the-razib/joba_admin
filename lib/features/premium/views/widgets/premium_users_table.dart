import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/empty_state.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/core/widgets/pagination_bar.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

/// Card containing search, paginated data table and pagination bar for subscribed Premium Users.
class PremiumUsersTable extends GetView<PremiumController> {
  const PremiumUsersTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilterBar(
              searchController: controller.searchController,
              searchHint: 'Search premium users by name or email...',
              onSearchChanged: (_) => controller.searchTick.value++,
            ),
          ),
          Obx(() {
            controller.searchTick.value;
            return AdaptiveDataTable<AppUser>(
              rows: controller.paginatedUsers,
              empty: const EmptyState(
                icon: Icons.workspace_premium_outlined,
                title: 'No premium users found',
                subtitle:
                    'There are currently no active paid subscribers in the database.',
              ),
              cardBuilder: (context, u) => Padding(
                padding: const EdgeInsets.all(14),
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
                            style: TextStyle(
                              color: context.palette.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Since ${formatDate(u.joinedAt)}',
                            style: TextStyle(
                              color: context.palette.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    userPlanBadge(u.plan),
                  ],
                ),
              ),
              columns: [
                AdaptiveColumn<AppUser>(
                  label: 'User',
                  flex: 5,
                  build: (context, u) => Row(
                    children: [
                      AvatarCircle(name: u.name, size: 36),
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
                    ],
                  ),
                ),
                AdaptiveColumn<AppUser>(
                  label: 'Plan',
                  flex: 2,
                  build: (context, u) => userPlanBadge(u.plan),
                ),
                AdaptiveColumn<AppUser>(
                  label: 'Member Since',
                  flex: 3,
                  build: (context, u) => Text(
                    formatDate(u.joinedAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                AdaptiveColumn<AppUser>(
                  label: 'Last Active',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, u) => Text(
                    timeAgo(u.lastActive),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                AdaptiveColumn<AppUser>(
                  label: 'Status',
                  flex: 2,
                  build: (context, u) => userStatusBadge(u.status),
                ),
              ],
            );
          }),
          Obx(() {
            final total = controller.filteredUsers.length;
            if (total == 0) return const SizedBox.shrink();
            return PaginationBar(
              page: controller.page.value,
              totalItems: total,
              pageSize: controller.pageSize.value,
              onPageChanged: (p) => controller.page.value = p,
              onPageSizeChanged: (s) {
                controller.pageSize.value = s;
                controller.page.value = 1;
              },
            );
          }),
        ],
      ),
    );
  }
}
