import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';

/// Branded splash. Advances to login after a short delay.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Waits for the saved session to load (and a minimum splash time), then
  /// routes to Home if logged in, else Login.
  Future<void> _bootstrap() async {
    final auth = context.read<AuthRepository>();
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1500)),
      auth.isLoaded ? Future<void>.value() : auth.load(),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      auth.isLoggedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.grad1, AppColors.bg, AppColors.bg],
            stops: [0, 0.7, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.graphic_eq,
                        color: AppColors.accent, size: 52),
                    const SizedBox(width: 12),
                    Text('dhun',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 72)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Every tune, every language',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                const Spacer(),
                const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
