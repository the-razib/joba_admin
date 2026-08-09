import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/app_user.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/core/widgets/pagination_bar.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';
import 'package:joba_admin/features/users/views/user_detail_panel.dart';

/// Side of one square tap target in the row action cluster.
const double _slot = 34;

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(mobile ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stats(context),
                const SizedBox(height: 16),
                FilterBar(
                  searchController: controller.searchController,
                  searchHint: 'Search by name, email or user ID...',
                  onSearchChanged: (_) => controller.page.value = 1,
                  onClear: controller.clearFilters,
                  filters: [
                    FilterOption(
                      label: 'All Status',
                      options: const [
                        'All Status',
                        'Active',
                        'Inactive',
                        'Blocked',
                      ],
                      selected: controller.statusFilter.value,
                      onChanged: (v) => controller.statusFilter.value = v,
                    ),
                    FilterOption(
                      label: 'All Plans',
                      options: const ['All Plans', 'Free', 'Premium'],
                      selected: controller.planFilter.value,
                      onChanged: (v) => controller.planFilter.value = v,
                    ),
                    FilterOption(
                      label: 'All Countries',
                      options: ['All Countries', ...controller.countries],
                      selected: controller.countryFilter.value,
                      onChanged: (v) => controller.countryFilter.value = v,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        AdaptiveDataTable<AppUser>(
                          rows: controller.paged,
                          onRowTap: (u) => openUserDetail(context, u.uid),
                          cardBuilder: (context, u) => _mobileCard(context, u),
                          columns: [
                            AdaptiveColumn<AppUser>(
                              label: 'User',
                              flex: 4,
                              build: (context, u) => Row(
                                children: [
                                  AvatarCircle(name: u.name, size: 38),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color:
                                                context.palette.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                            AdaptiveColumn<AppUser>(
                              label: 'Status',
                              build: (context, u) => Align(
                                alignment: Alignment.centerLeft,
                                child: userStatusBadge(u.status),
                              ),
                            ),
                            AdaptiveColumn<AppUser>(
                              label: 'Plan',
                              build: (context, u) => Align(
                                alignment: Alignment.centerLeft,
                                child: userPlanBadge(u.plan),
                              ),
                            ),
                            AdaptiveColumn<AppUser>(
                              label: 'Country',
                              tabletHidden: true,
                              build: (context, u) => Text(
                                '${u.flagEmoji} ${u.country}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.palette.textPrimary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            AdaptiveColumn<AppUser>(
                              label: 'Joined',
                              build: (context, u) => Text(
                                formatDate(u.joinedAt),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.palette.textPrimary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            AdaptiveColumn<AppUser>(
                              label: 'Last Active',
                              tabletHidden: true,
                              build: (context, u) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: u.status == UserStatus.active
                                          ? AppColors.success
                                          : context.palette.textSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      timeAgo(u.lastActive),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.palette.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AdaptiveColumn<AppUser>(
                              label: 'Actions',
                              // Three pinned slots: view, edit, overflow menu.
                              width: _slot * 3,
                              align: Alignment.centerRight,
                              build: (context, u) => _actions(context, u),
                            ),
                          ],
                        ),
                        Divider(height: 1, color: context.palette.border),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: PaginationBar(
                            page: controller.page.value,
                            totalItems: controller.filtered.length,
                            pageSize: controller.pageSize.value,
                            onPageChanged: (p) => controller.page.value = p
                                .clamp(1, controller.totalPages),
                            onPageSizeChanged: (s) {
                              controller.pageSize.value = s;
                              controller.page.value = 1;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _stats(BuildContext context) {
    const stats = [
      (
        Icons.group_outlined,
        'Total Users',
        '24,789',
        12.5,
        'vs last 7 days',
        AppColors.primary,
      ),
      (
        Icons.monitor_heart_outlined,
        'Active Today',
        '4,278',
        8.3,
        'vs yesterday',
        AppColors.purple,
      ),
      (
        Icons.person_add_alt_outlined,
        'New Users (Today)',
        '689',
        15.2,
        'vs yesterday',
        AppColors.accent,
      ),
      (
        Icons.workspace_premium_outlined,
        'Premium Users',
        '2,356',
        10.1,
        'vs last 7 days',
        AppColors.warning,
      ),
      (
        Icons.calendar_month_outlined,
        'Avg. Cycle Length',
        '28.7',
        -1.3,
        'vs last 30 days',
        AppColors.info,
      ),
    ];
    final count = Responsive.pick(context, mobile: 2, tablet: 3, desktop: 5);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisExtent: 104,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => StatCard(
        icon: stats[i].$1,
        label: stats[i].$2,
        value: stats[i].$3,
        deltaPercent: stats[i].$4,
        compareLabel: stats[i].$5,
        iconColor: stats[i].$6,
      ),
    );
  }

  /// Every slot is pinned to a fixed square. `PopupMenuButton` has no intrinsic
  /// width — offered a bounded box it expands to fill it — so the cluster has to
  /// be sized from the outside, otherwise the column can never be made to fit.
  Widget _actions(BuildContext context, AppUser u) {
    const box = BoxConstraints(minWidth: _slot, minHeight: _slot);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _slot,
          height: _slot,
          child: IconButton(
            tooltip: 'View',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: box,
            icon: const Icon(
              Icons.visibility_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            onPressed: () => openUserDetail(context, u.uid),
          ),
        ),
        SizedBox(
          width: _slot,
          height: _slot,
          child: IconButton(
            tooltip: 'Edit',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: box,
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.info,
            ),
            onPressed: () => openUserDetail(context, u.uid),
          ),
        ),
        SizedBox(
          width: _slot,
          height: _slot,
          child: PopupMenuButton<String>(
            tooltip: 'More',
            padding: EdgeInsets.zero,
            iconSize: 18,
            onSelected: (v) => _menuAction(context, u, v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'block',
                child: Text(
                  u.status == UserStatus.blocked
                      ? 'Unblock user'
                      : 'Block user',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete user',
                  style: TextStyle(fontSize: 13, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _menuAction(BuildContext context, AppUser u, String v) async {
    if (v == 'block') {
      controller.updateStatus(
        u.uid,
        u.status == UserStatus.blocked ? UserStatus.active : UserStatus.blocked,
      );
      Get.snackbar(
        'User updated',
        '${u.name} ${u.status == UserStatus.blocked ? 'unblocked' : 'blocked'} (mock).',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (v == 'delete') {
      final ok = await showConfirmDialog(
        context,
        title: 'Delete user?',
        message:
            'This permanently removes ${u.name} and their data. This action cannot be undone.',
        confirmLabel: 'Delete',
        danger: true,
      );
      if (ok) {
        controller.remove(u.uid);
        Get.snackbar(
          'User deleted',
          '${u.name} removed (mock).',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Widget _mobileCard(BuildContext context, AppUser u) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarCircle(name: u.name, size: 42),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.name,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        u.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _actions(context, u),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                userStatusBadge(u.status),
                userPlanBadge(u.plan),
                Text(
                  '${u.flagEmoji} ${u.country}',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Joined ${formatDate(u.joinedAt)} • ${timeAgo(u.lastActive)}',
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
