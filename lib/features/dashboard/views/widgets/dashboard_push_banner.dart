import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

/// Call-to-action banner promoting push notifications engagement.
class DashboardPushBanner extends StatelessWidget {
  const DashboardPushBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: context.palette.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mark_chat_unread_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send a Push Notification',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reach your users instantly with updates and important notifications.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => shell.select(NavId.push),
            icon: const Icon(Icons.send, size: 16),
            label: Responsive.isMobile(context)
                ? const SizedBox()
                : const Text('Send Notification'),
          ),
        ],
      ),
    );
  }
}
