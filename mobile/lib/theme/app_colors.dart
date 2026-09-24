import 'package:flutter/material.dart';

/// Color tokens lifted from the Studeck Figma file.
class AppColors {
  AppColors._();

  // Backgrounds
  static const background = Color(0xFF14102B);
  static const surface = Color(0xFF1E1A3D);
  static const surfaceBorder = Color(0xFF2E2A55);
  static const surfaceElevated = Color(0xFF221D45);

  // Brand / accent
  static const primary = Color(0xFF6C5CE7);
  static const primaryPressed = Color(0xFF5B4BD1);

  // Text
  static const textPrimary = Color(0xFFF5F4FF);
  static const textSecondary = Color(0xFFA6A2C4);
  static const textMuted = Color(0xFF716D95);

  // Status
  static const success = Color(0xFF22C55E);
  static const successSurface = Color(0xFF2E7D4F);
  static const warning = Color(0xFFC9962C);
  static const warningSurface = Color(0xFFA9791F);
  static const danger = Color(0xFFEF4444);
  static const dangerSurface = Color(0xFF7A2323);

  // Tag pills
  static const tagViolet = Color(0xFF6C5CE7);
  static const tagGreen = Color(0xFF22C55E);
  static const tagNeutral = Color(0xFF3A3564);
}
