import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';

/// Card containing the data table for subscribed Premium Users.
class PremiumUsersTable extends GetView<PremiumController> {
  const PremiumUsersTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AdaptiveDataTable<AppUser>(
        rows: controller.users,
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
            label: 'Renews',
            flex: 3,
            tabletHidden: true,
            build: (context, u) => Text(
              formatDate(u.joinedAt.add(const Duration(days: 365))),
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
            build: (context, u) =>
                const PillBadge(label: 'Active', color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
