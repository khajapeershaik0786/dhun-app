import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/theme_controller.dart';
import '../widgets/profile_avatar.dart';

/// Settings: profile summary, appearance (theme), and account actions.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileRepository>();
    final theme = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Profile card.
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  ProfileAvatar(profile: profile, size: 60),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.fullName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(
                          profile.email.isEmpty
                              ? 'View profile'
                              : profile.email,
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const _SectionHeader('Appearance'),
          _ThemeOption(
            label: 'System default',
            icon: Icons.brightness_auto,
            value: ThemeMode.system,
            group: theme.mode,
            onTap: () => theme.setMode(ThemeMode.system),
          ),
          _ThemeOption(
            label: 'Light',
            icon: Icons.light_mode,
            value: ThemeMode.light,
            group: theme.mode,
            onTap: () => theme.setMode(ThemeMode.light),
          ),
          _ThemeOption(
            label: 'Dark',
            icon: Icons.dark_mode,
            value: ThemeMode.dark,
            group: theme.mode,
            onTap: () => theme.setMode(ThemeMode.dark),
          ),
          const _SectionHeader('Account'),
          ListTile(
            leading: Icon(Icons.person_outline, color: AppColors.text),
            title: const Text('Edit profile'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
            title: const Text('Log out',
                style: TextStyle(color: Color(0xFFEF4444))),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final nav = Navigator.of(context);
    await context.read<AuthRepository>().logOut();
    nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(title.toUpperCase(),
          style: TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w800)),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.group,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: selected ? AppColors.accent : AppColors.text),
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.accent)
          : Icon(Icons.circle_outlined, color: AppColors.textFaint),
    );
  }
}
