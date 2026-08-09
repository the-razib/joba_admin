import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

/// Joba brand mark.
///
/// The source PNG is a full-bleed square with no built-in corner radius, so it
/// is always clipped to the rounded-square app-icon silhouette.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 42, this.glow = false});

  static const asset = 'assets/icons/app_icon.png';

  final double size;

  /// Accent-tinted drop shadow, for the logo standing alone on a plain
  /// background (login) rather than inside a dense bar.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.29);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
