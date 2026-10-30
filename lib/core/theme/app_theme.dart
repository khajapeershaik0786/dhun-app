import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Builds the light and dark [ThemeData] for dhun from the explicit palettes
/// in [AppColors]. Screen code uses the dynamic [AppColors] getters.
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final base = ThemeData(brightness: b, useMaterial3: true);

    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceHigh =
        isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurfaceHigh;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: b,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      surface: bg,
      onSurface: text,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      dividerColor: divider,
      splashColor: AppColors.accent.withValues(alpha: 0.12),
      highlightColor: AppColors.accent.withValues(alpha: 0.08),
      textTheme: _textTheme(base.textTheme, text),
      iconTheme: IconThemeData(color: text),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: text,
        inactiveTrackColor: surfaceHigh,
        thumbColor: text,
        trackHeight: 3,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color c) {
    return base.apply(bodyColor: c, displayColor: c).copyWith(
          displayLarge: TextStyle(
            color: c,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            height: 0.95,
          ),
          displaySmall: TextStyle(
            color: c,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1,
          ),
          headlineSmall: TextStyle(
            color: c,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          titleLarge: TextStyle(color: c, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: c, fontWeight: FontWeight.w700),
          labelLarge: TextStyle(
            color: c,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        );
  }
}
