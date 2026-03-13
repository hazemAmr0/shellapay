import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFAC58FF); // Vibrant Purple
  static const Color primaryLight = Color(0xFFD09CFF);
  static const Color primaryDark = Color(0xFF7A20D6);

  static const Color secondary = Color(0xFF00E5FF); // Neon Cyan
  static const Color accent = Color(0xFFFF3D00); // Neon Orange

  // Backgrounds (Dark Mode Focus)
  static const Color background = Color(0xFF101014);
  static const Color surface = Color(0xFF1A1A22);
  static const Color surfaceElevated = Color(0xFF252530);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0B0);
  static const Color textMuted = Color(0xFF6A6A78);

  // States
  static const Color success = Color(0xFF00FF88);
  static const Color error = Color(0xFFFF1E56);
  static const Color warning = Color(0xFFFFB300);

  // Borders & Dividers
  static const Color border = Color(0xFF303040);
  static const Color divider = Color(0xFF22222C);
}

class AppConstants {
  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXl = 32.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
}
