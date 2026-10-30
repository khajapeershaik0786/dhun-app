import 'package:flutter/material.dart';

/// Theme-aware palette for dhun. Screen code reads the dynamic getters
/// (e.g. [AppColors.bg]); the app sets [AppColors.brightness] from the resolved
/// theme on every build so those getters return the right value.
///
/// Brand colours (accent, gradients) are shared across both modes.
class AppColors {
  AppColors._();

  /// Set by the app from the active theme's brightness before screens build.
  static Brightness brightness = Brightness.dark;
  static bool get isDark => brightness == Brightness.dark;

  // ── Brand (shared) ─────────────────────────────────────────────
  static const Color accent = Color(0xFF1ED760);
  static const Color accentDim = Color(0xFF1DB954);
  static const Color onAccent = Color(0xFF05140A);

  static const Color grad1 = Color(0xFF7C3AED);
  static const Color grad2 = Color(0xFFEC4899);
  static const Color grad3 = Color(0xFF2DD4BF);

  static const List<Color> heroGradient = [grad1, grad2];

  static const List<List<Color>> cardGradients = [
    [Color(0xFF7C3AED), Color(0xFFEC4899)],
    [Color(0xFF2563EB), Color(0xFF2DD4BF)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF10B981), Color(0xFF3B82F6)],
    [Color(0xFFEC4899), Color(0xFFF59E0B)],
    [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
  ];

  static List<Color> gradientFor(Object seed) =>
      cardGradients[seed.hashCode.abs() % cardGradients.length];

  // ── Dark palette (raw) ─────────────────────────────────────────
  static const Color darkBg = Color(0xFF0D0D10);
  static const Color darkBgElevated = Color(0xFF16161C);
  static const Color darkSurface = Color(0xFF1E1E26);
  static const Color darkSurfaceHigh = Color(0xFF2A2A34);
  static const Color darkDivider = Color(0xFF2C2C36);
  static const Color darkText = Color(0xFFF5F5F7);
  static const Color darkTextMuted = Color(0xFFB3B3BD);
  static const Color darkTextFaint = Color(0xFF6E6E78);

  // ── Light palette (raw) ────────────────────────────────────────
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightBgElevated = Color(0xFFF6F6F9);
  static const Color lightSurface = Color(0xFFF0F0F4);
  static const Color lightSurfaceHigh = Color(0xFFE3E3EA);
  static const Color lightDivider = Color(0xFFE2E2E8);
  static const Color lightText = Color(0xFF15151A);
  static const Color lightTextMuted = Color(0xFF5B5B66);
  static const Color lightTextFaint = Color(0xFF9A9AA4);

  // ── Dynamic getters (used by screens) ──────────────────────────
  static Color get bg => isDark ? darkBg : lightBg;
  static Color get bgElevated => isDark ? darkBgElevated : lightBgElevated;
  static Color get surface => isDark ? darkSurface : lightSurface;
  static Color get surfaceHigh => isDark ? darkSurfaceHigh : lightSurfaceHigh;
  static Color get divider => isDark ? darkDivider : lightDivider;
  static Color get text => isDark ? darkText : lightText;
  static Color get textMuted => isDark ? darkTextMuted : lightTextMuted;
  static Color get textFaint => isDark ? darkTextFaint : lightTextFaint;
}
