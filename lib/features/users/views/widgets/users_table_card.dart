import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/pagination_bar.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';
import 'package:joba_admin/features/users/views/user_detail_panel.dart';
import 'package:joba_admin/features/users/views/widgets/user_action_buttons.dart';
import 'package:joba_admin/features/users/views/widgets/user_mobile_card.dart';

const double _slot = 34;

/// Main table card displaying the paginated list of users with desktop/mobile adaptive layouts.
class UsersTableCard extends GetView<UsersController> {
  const UsersTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Obx(
              () => AdaptiveDataTable<AppUser>(
                rows: controller.paged,
                onRowTap: (u) => openUserDetail(context, u.uid),
                cardBuilder: (context, u) => UserMobileCard(user: u),
                columns: [
                  AdaptiveColumn<AppUser>(
                    label: 'User',
                    flex: 4,
                    build: (context, u) => Row(
                      children: [
                        AvatarCircle(
                          name: u.name,
                          url: u.photoUrl,
                          size: 38,
                        ),
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
                              const SizedBox(height: 2),
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
                    width: _slot * 3,
                    align: Alignment.centerRight,
                    build: (context, u) => UserActionButtons(user: u),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.palette.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Obx(
                () => PaginationBar(
                  page: controller.page.value,
                  totalItems: controller.filtered.length,
                  pageSize: controller.pageSize.value,
                  onPageChanged: (p) => controller.page.value =
                      p.clamp(1, controller.totalPages),
                  onPageSizeChanged: (s) {
                    controller.pageSize.value = s;
                    controller.page.value = 1;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
