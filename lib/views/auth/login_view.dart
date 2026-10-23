import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../widgets/primary_button.dart';

/// Login screen (dark). A valid submit replaces the stack with the home shell.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.graphic_eq, color: AppColors.accent, size: 26),
                  const SizedBox(width: 8),
                  Text('dhun',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 24, color: AppColors.accent)),
                ],
              ),
              const SizedBox(height: 28),
              Text('Welcome\nback.',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 46)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      _Field(
                        label: 'Mobile number or email',
                        hint: 'you@example.com',
                        onChanged: vm.setIdentifier,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _Field(
                        label: 'Password',
                        hint: '••••••••',
                        obscure: vm.obscurePassword,
                        onChanged: vm.setPassword,
                        suffix: TextButton(
                          onPressed: vm.toggleObscure,
                          child: Text(vm.obscurePassword ? 'Show' : 'Hide',
                              style: const TextStyle(color: AppColors.accent)),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Forgot password?',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Log in',
                        enabled: vm.canSubmit,
                        onPressed: () {
                          if (vm.submit()) {
                            context.read<AuthRepository>().logIn();
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.home);
                          }
                        },
                      ),
                      const _OrDivider(),
                      const _SocialButton(icon: Icons.apple, label: 'Continue with Apple'),
                      const SizedBox(height: 10),
                      const _SocialButton(icon: Icons.g_mobiledata, label: 'Continue with Google'),
                    ],
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New to dhun? ',
                        style: TextStyle(color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.signup),
                      child: const Text('Create account',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.onChanged,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscure,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textFaint),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.divider)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('or', style: TextStyle(color: AppColors.textFaint)),
          ),
          Expanded(child: Divider(color: AppColors.divider)),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.text, size: 22),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.text)),
        ],
      ),
    );
  }
}
