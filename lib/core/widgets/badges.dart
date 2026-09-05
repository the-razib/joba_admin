import 'package:flutter/material.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

/// Soft-tinted pill badge used across tables and detail panels.
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ] else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

PillBadge userStatusBadge(UserStatus s) => switch (s) {
  UserStatus.active => const PillBadge(
    label: 'Active',
    color: AppColors.success,
  ),
  UserStatus.inactive => const PillBadge(
    label: 'Inactive',
    color: AppColors.warning,
  ),
  UserStatus.blocked => const PillBadge(
    label: 'Blocked',
    color: AppColors.danger,
  ),
};

PillBadge userPlanBadge(UserPlan p) => switch (p) {
  UserPlan.premium => const PillBadge(
    label: 'Premium',
    color: AppColors.primary,
    icon: Icons.workspace_premium,
  ),
  UserPlan.free => const PillBadge(
    label: 'Free',
    color: AppColors.purple,
    icon: Icons.auto_awesome,
  ),
};

PillBadge articleStatusBadge(ArticleStatus s) => switch (s) {
  ArticleStatus.published => const PillBadge(
    label: 'Published',
    color: AppColors.success,
  ),
  ArticleStatus.draft => const PillBadge(
    label: 'Draft',
    color: AppColors.textSecondaryLight,
  ),
  ArticleStatus.review => const PillBadge(
    label: 'Review',
    color: AppColors.warning,
  ),
};

PillBadge reportStatusBadge(ReportStatus s) => switch (s) {
  ReportStatus.pending => const PillBadge(
    label: 'Pending',
    color: AppColors.warning,
  ),
  ReportStatus.inProgress => const PillBadge(
    label: 'In Progress',
    color: AppColors.purple,
  ),
  ReportStatus.resolved => const PillBadge(
    label: 'Resolved',
    color: AppColors.success,
  ),
};

PillBadge reportPriorityBadge(ReportPriority p) => switch (p) {
  ReportPriority.high => const PillBadge(
    label: 'High',
    color: AppColors.danger,
  ),
  ReportPriority.medium => const PillBadge(
    label: 'Medium',
    color: AppColors.warning,
  ),
  ReportPriority.low => const PillBadge(label: 'Low', color: AppColors.success),
};

PillBadge reportTypeBadge(ReportType t) => switch (t) {
  ReportType.bug => const PillBadge(
    label: 'Bug Report',
    color: AppColors.success,
  ),
  ReportType.prediction => const PillBadge(
    label: 'Prediction Issue',
    color: AppColors.accent,
  ),
  ReportType.content => const PillBadge(
    label: 'Content Issue',
    color: AppColors.warning,
  ),
  ReportType.feature => const PillBadge(
    label: 'Feature Request',
    color: AppColors.purple,
  ),
  ReportType.payment => const PillBadge(
    label: 'Payment Issue',
    color: AppColors.accent,
  ),
  ReportType.other => const PillBadge(label: 'Other', color: AppColors.info),
};

/// High-visibility red NEW tag badge for unread reports
Widget reportNewBadge() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          height: 1.1,
        ),
      ),
    );

