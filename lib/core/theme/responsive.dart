import 'package:flutter/material.dart';

/// Breakpoints for the responsive admin shell.
///
/// - mobile  < 700   : bottom nav + drawer, card lists, drill-down navigation
/// - tablet  700-1100: icon-rail sidebar, two-pane layouts
/// - desktop >= 1100 : full sidebar, three-pane layouts, full tables
class Responsive {
  Responsive._();

  static const double mobileMax = 700;
  static const double desktopMin = 1100;
  static const double wideMin = 1440;
  static const double contentMax = 1600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileMax && w < desktopMin;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopMin;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideMin;

  /// Picks a value by breakpoint (mobile first).
  static T pick<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}
