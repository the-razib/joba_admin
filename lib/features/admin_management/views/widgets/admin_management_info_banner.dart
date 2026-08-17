import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Information banner explaining Phase 3 Firebase custom claims role enforcement.
class AdminManagementInfoBanner extends StatelessWidget {
  const AdminManagementInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 17,
            color: AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Phase 3 enforces roles with Firebase custom claims: Super Admin (all), Editor (content), Viewer (read-only).',
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
