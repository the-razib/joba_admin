import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

/// Context-aware semantic palette (light/dark).
class AppPalette {
  const AppPalette({
    required this.background,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.inputFill,
  });

  final Color background;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color inputFill;

  static const light = AppPalette(
    background: AppColors.backgroundLight,
    card: AppColors.cardLight,
    border: AppColors.borderLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    inputFill: Color(0xFFF1F4F2),
  );

  static const dark = AppPalette(
    background: AppColors.backgroundDark,
    card: AppColors.cardDark,
    border: AppColors.borderDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    inputFill: Color(0xFF1A2C24),
  );
}

extension ThemeContextX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  AppPalette get palette => isDark ? AppPalette.dark : AppPalette.light;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final palette = isLight ? AppPalette.light : AppPalette.dark;
    final textTheme = GoogleFonts.interTextTheme(
      isLight ? _lightText() : _darkText(),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: palette.card,
      ),
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        border: _outline(palette),
        enabledBorder: _outline(palette),
        focusedBorder: _outline(palette, color: AppColors.primary),
        errorBorder: _outline(palette, color: AppColors.danger),
        focusedErrorBorder: _outline(palette, color: AppColors.danger),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.inputFill,
        side: BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(color: palette.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.border),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.sidebarBg,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: palette.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.sidebarBg,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static TextTheme _lightText() => TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
        bodySmall: TextStyle(color: AppColors.textSecondaryLight),
        labelLarge: TextStyle(color: AppColors.textPrimaryLight),
      );

  static TextTheme _darkText() => TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark),
        labelLarge: TextStyle(color: AppColors.textPrimaryDark),
      );

  static OutlineInputBorder _outline(AppPalette palette, {Color? color}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color ?? palette.border),
      );

  /// Bengali typeface for BN content previews.
  static TextStyle bengali(BuildContext context, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.hindSiliguri(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? context.palette.textPrimary,
      );
}
