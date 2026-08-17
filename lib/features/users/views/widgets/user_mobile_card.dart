import 'package:flutter/material.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/features/users/views/widgets/user_action_buttons.dart';

/// Card layout for an individual user on mobile screen sizes.
class UserMobileCard extends StatelessWidget {
  const UserMobileCard({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final u = user;

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
                UserActionButtons(user: u),
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
