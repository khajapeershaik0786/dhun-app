import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Global dark [ThemeData] for dhun, styled after Spotify / JioSaavn.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final scheme = const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.grad2,
      surface: AppColors.bg,
      onSurface: AppColors.text,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      dividerColor: AppColors.divider,
      splashColor: AppColors.accent.withValues(alpha: 0.12),
      highlightColor: AppColors.accent.withValues(alpha: 0.08),
      textTheme: _textTheme(base.textTheme),
      iconTheme: const IconThemeData(color: AppColors.text),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.text,
        inactiveTrackColor: AppColors.surfaceHigh,
        thumbColor: AppColors.text,
        trackHeight: 3,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    const c = AppColors.text;
    return base.apply(bodyColor: c, displayColor: c).copyWith(
          displayLarge: const TextStyle(
            color: c,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            height: 0.95,
          ),
          displaySmall: const TextStyle(
            color: c,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1,
          ),
          headlineSmall: const TextStyle(
            color: c,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          titleLarge: const TextStyle(color: c, fontWeight: FontWeight.w700),
          titleMedium: const TextStyle(color: c, fontWeight: FontWeight.w700),
          labelLarge: const TextStyle(
            color: c,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        );
  }
}
