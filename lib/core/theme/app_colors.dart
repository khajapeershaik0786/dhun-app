import 'package:flutter/material.dart';

/// Spotify / JioSaavn-inspired dark palette for dhun.
class AppColors {
  AppColors._();

  // Base surfaces (near-black, layered greys).
  static const Color bg = Color(0xFF0D0D10);
  static const Color bgElevated = Color(0xFF16161C);
  static const Color surface = Color(0xFF1E1E26);
  static const Color surfaceHigh = Color(0xFF2A2A34);
  static const Color divider = Color(0xFF2C2C36);

  // Primary accent — vivid green (Spotify), with a lighter pressed tint.
  static const Color accent = Color(0xFF1ED760);
  static const Color accentDim = Color(0xFF1DB954);

  // Secondary accents used for gradient headers (JioSaavn vibe).
  static const Color grad1 = Color(0xFF7C3AED); // violet
  static const Color grad2 = Color(0xFFEC4899); // pink
  static const Color grad3 = Color(0xFF2DD4BF); // teal

  // Text.
  static const Color text = Color(0xFFF5F5F7);
  static const Color textMuted = Color(0xFFB3B3BD);
  static const Color textFaint = Color(0xFF6E6E78);

  static const Color onAccent = Color(0xFF05140A);

  /// A warm-to-cool brand gradient for hero headers / artwork fallbacks.
  static const List<Color> heroGradient = [grad1, grad2];

  /// Rotating gradient pairs so cards/headers feel varied like Saavn.
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
}
