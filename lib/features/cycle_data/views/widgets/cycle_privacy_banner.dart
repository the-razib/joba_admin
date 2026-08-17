import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Privacy and security advisory banner regarding sensitive cycle health data.
class CyclePrivacyBanner extends StatelessWidget {
  const CyclePrivacyBanner({super.key});

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
            Icons.privacy_tip_outlined,
            size: 17,
            color: AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cycle data is sensitive health information. Per-user views are restricted to Super Admins and recorded in Audit Logs. Default views are aggregate-only.',
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
