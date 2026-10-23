import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Album / episode artwork with a gradient fallback while loading or on error.
class Artwork extends StatelessWidget {
  const Artwork({
    super.key,
    required this.url,
    required this.size,
    this.seed = '',
    this.radius = 6,
  });

  final String url;
  final double size;
  final Object seed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.gradientFor(seed.toString().isEmpty ? url : seed);
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.music_note_rounded,
          color: Colors.white.withValues(alpha: 0.85), size: size * 0.4),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? fallback
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : fallback,
            ),
    );
  }
}
