import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/profile_repository.dart';

/// Shows the user's profile photo, or their initials on an accent circle when
/// no photo is set.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.size = 44});

  final ProfileRepository profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final file = profile.photoFile;
    if (file != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(file),
        backgroundColor: AppColors.surfaceHigh,
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        profile.initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
