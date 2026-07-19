import 'package:flutter/material.dart';

/// Shared design-system tokens for the entire app.
/// Palette, spacing (8dp grid), typography, and touch targets per design.md §1.
class DesignTokens {
  DesignTokens._();

  // ── Color palette (design.md §1.1) ──────────────────────────────
  static const Color colorPrimary = Color(0xFF0D9488); // Teal 600
  static const Color colorSecondary = Color(0xFF0F172A); // Slate 900
  static const Color colorBgDark = Color(0xFFF8FAFC); // Slate 50
  static const Color colorSurface = Color(0xFFFFFFFF); // White
  static const Color colorTextMain = Color(0xFF1E293B); // Slate 800
  static const Color colorTextMuted = Color(0xFF64748B); // Slate 500
  static const Color colorSuccess = Color(0xFF16A34A); // Green 600
  static const Color colorWarning = Color(0xFFD97706); // Amber 600
  static const Color colorDanger = Color(0xFFDC2626); // Red 600
  static const Color colorBackground = colorBgDark;

  // ── Spacing (8dp grid, design.md §1.2) ─────────────────────────
  static const double kSpace4 = 4.0;
  static const double kSpace8 = 8.0;
  static const double kSpace12 = 12.0;
  static const double kSpace16 = 16.0;
  static const double kSpace24 = 24.0;
  static const double kSpace32 = 32.0;
  static const double kSpace48 = 48.0;

  /// Standard horizontal edge padding for mobile screens.
  static const double kEdgeMargin = kSpace16;

  /// Minimum touch target size (design.md §1.2).
  static const double kTouchMin = 48.0;

  // ── Typography builders (design.md §1.3) ────────────────────────
  static const String fontFamily = 'Roboto';

  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: colorTextMain,
    fontFamily: fontFamily,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: colorTextMain,
    fontFamily: fontFamily,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: colorTextMain,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: colorTextMain,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
    color: colorTextMain,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: colorTextMuted,
    fontFamily: fontFamily,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 16 / 14,
    color: colorTextMain,
    fontFamily: fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: colorTextMuted,
    fontFamily: fontFamily,
  );
}
