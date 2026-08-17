import 'package:flutter/material.dart';
import 'package:joba_admin/features/admin_management/models/admin_profile.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_role_badge.dart';

/// Card layout for displaying an admin team member on compact mobile screens.
class AdminManagementMobileCard extends StatelessWidget {
  final AdminProfile admin;

  const AdminManagementMobileCard({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    final a = admin;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(name: a.name, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.name,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      a.email,
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              AdminRoleBadge(role: a.role),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last active ${timeAgo(a.lastActive)} • ${a.active ? 'Active' : 'Disabled'}',
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
