import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

enum ToastType { success, error, info, warning }

/// Enterprise floating toast notification for web & desktop dashboards.
/// Provides compact top-right floating toasts with icons, status badges, and dismiss buttons.
class AppToast {
  AppToast._();

  static void success(String title, [String? message]) {
    show(title: title, message: message, type: ToastType.success);
  }

  static void error(String title, [String? message]) {
    show(title: title, message: message, type: ToastType.error);
  }

  static void info(String title, [String? message]) {
    show(title: title, message: message, type: ToastType.info);
  }

  static void warning(String title, [String? message]) {
    show(title: title, message: message, type: ToastType.warning);
  }

  static void show({
    required String title,
    String? message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    if (Get.testMode && (Get.key.currentState == null || Get.key.currentState?.overlay == null)) {
      return;
    }
    final context = Get.context;
    final isDark = context != null ? Theme.of(context).brightness == Brightness.dark : true;
    final palette = isDark ? AppPalette.dark : AppPalette.light;

    Color badgeColor;
    IconData icon;
    switch (type) {
      case ToastType.success:
        badgeColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        badgeColor = AppColors.danger;
        icon = Icons.error_rounded;
        break;
      case ToastType.warning:
        badgeColor = AppColors.warning;
        icon = Icons.warning_rounded;
        break;
      case ToastType.info:
        badgeColor = AppColors.info;
        icon = Icons.info_rounded;
        break;
    }

    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      maxWidth: 420,
      margin: const EdgeInsets.only(top: 18, right: 18, left: 18),
      padding: EdgeInsets.zero,
      borderRadius: 14,
      backgroundColor: Colors.transparent,
      duration: duration,
      animationDuration: const Duration(milliseconds: 260),
      messageText: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              margin: const EdgeInsets.only(top: 1),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: badgeColor, size: 18),
            ),
            const SizedBox(width: 12),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (message != null && message.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Close button
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                if (Get.isSnackbarOpen) {
                  Get.closeCurrentSnackbar();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: palette.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
