import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Information banner explaining Phase 1 vs Phase 3 avatar storage.
class AvatarInfoBanner extends StatelessWidget {
  const AvatarInfoBanner({super.key});

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
            Icons.info_outline,
            size: 17,
            color: AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Phase 1 shows the avatars bundled with the app. In Phase 3, uploads go to Firebase Storage and are served from the avatars collection.',
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
