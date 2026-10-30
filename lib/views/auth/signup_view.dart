import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../widgets/primary_button.dart';

/// Sign-up screen (dark). Collects details + languages, then enters the shell.
class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignupViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Create account',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STEP 1 OF 2',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Join dhun.',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 40)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),
                      _Field(label: 'Full name', hint: 'Ananya Rao', onChanged: vm.setName),
                      const SizedBox(height: 14),
                      _Field(
                          label: 'Mobile number',
                          hint: '+91 ',
                          keyboardType: TextInputType.phone,
                          onChanged: vm.setMobile),
                      const SizedBox(height: 14),
                      _Field(
                          label: 'Password',
                          hint: '8+ characters',
                          obscure: true,
                          onChanged: vm.setPassword),
                      const SizedBox(height: 20),
                      Text('Languages you listen to',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: vm.languages.map((lang) {
                          final selected = vm.isLanguageSelected(lang);
                          return GestureDetector(
                            onTap: () => vm.toggleLanguage(lang),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(lang,
                                  style: TextStyle(
                                      color: selected
                                          ? AppColors.onAccent
                                          : AppColors.text,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                label: 'Create account',
                enabled: vm.canSubmit,
                onPressed: () {
                  if (vm.submit()) {
                    context.read<AuthRepository>().logIn(name: vm.name);
                    context
                        .read<ProfileRepository>()
                        .seedIfEmpty(name: vm.name);
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                  }
                },
              ),
              const SizedBox(height: 10),
              Text('By continuing you agree to Terms & Privacy Policy.',
                  style: TextStyle(color: AppColors.textFaint, fontSize: 11)),
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
    this.keyboardType,
  });

  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscure,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textFaint),
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
