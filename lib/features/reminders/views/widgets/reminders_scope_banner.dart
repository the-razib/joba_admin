import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Informational banner clarifying that the sequence is global.
class RemindersScopeBanner extends StatelessWidget {
  const RemindersScopeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This order is global. Users still choose which reminders to '
              'switch on and when medicine fires — the admin panel only decides '
              'the sequence they are planned in on the home screen.',
              style: TextStyle(color: palette.textPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
