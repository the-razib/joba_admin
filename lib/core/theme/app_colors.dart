import 'package:flutter/material.dart';

/// Brand + semantic color tokens sampled from modern enterprise dashboard guidelines.
class AppColors {
  AppColors._();

  // Brand / Action Colors
  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFFECFDF5);
  static const Color accent = Color(0xFFE65671); // Joba Rose / Pink
  static const Color accentLight = Color(0xFFFFF1F4);

  // Proper Pitch-Black Sidebar
  static const Color sidebarBg = Color(0xFF0C0D0E); // Proper Black
  static const Color sidebarActive = Color(0xFF1C1D21);
  static const Color sidebarHover = Color(0xFF16171A);
  static const Color sidebarBorder = Color(0xFF1E2024);
  static const Color sidebarText = Color(0xFF9496A1);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);

  // Light Theme Surfaces (Crisp & Clean)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color inputFillLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Dark Theme Surfaces (Professional Slate/Midnight Black)
  static const Color backgroundDark = Color(0xFF0B0F17);
  static const Color cardDark = Color(0xFF131B26);
  static const Color borderDark = Color(0xFF222C3D);
  static const Color inputFillDark = Color(0xFF161F2C);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
