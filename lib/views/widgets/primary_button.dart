import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Full-width accent pill call-to-action.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: active ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.surfaceHigh,
          disabledForegroundColor: AppColors.textFaint,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        child: Text(label),
      ),
    );
  }
}
