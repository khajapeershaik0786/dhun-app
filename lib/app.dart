import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/favourites_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/theme_controller.dart';
import 'data/services/audius_api.dart';
import 'data/services/itunes_api.dart';
import 'viewmodels/favourites_viewmodel.dart';
import 'viewmodels/player_viewmodel.dart';

/// Root widget. Wires app-wide services, repositories and the player, then
/// installs the light/dark themes + static route table.
class DhunApp extends StatelessWidget {
  const DhunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ItunesApi>(
          create: (_) => ItunesApi(),
          dispose: (_, api) => api.dispose(),
        ),
        Provider<AudiusApi>(
          create: (_) => AudiusApi(),
          dispose: (_, api) => api.dispose(),
        ),
        Provider<CatalogRepository>(
          create: (ctx) => CatalogRepository(
              ctx.read<AudiusApi>(), ctx.read<ItunesApi>()),
        ),
        ChangeNotifierProvider<AuthRepository>(
          lazy: false,
          create: (_) => AuthRepository()..load(),
        ),
        ChangeNotifierProvider<ThemeController>(
          lazy: false,
          create: (_) => ThemeController()..load(),
        ),
        ChangeNotifierProvider<ProfileRepository>(
          lazy: false,
          create: (_) => ProfileRepository()..load(),
        ),
        ChangeNotifierProvider<FavouritesRepository>(
          create: (_) => FavouritesRepository()..load(),
        ),
        ChangeNotifierProvider<PlayerViewModel>(
          create: (_) => PlayerViewModel(resolver: (t) async => t.streamUrl),
        ),
        ChangeNotifierProvider<FavouritesViewModel>(
          create: (ctx) =>
              FavouritesViewModel(ctx.read<FavouritesRepository>()),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'dhun',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.mode,
            // Keep the dynamic AppColors getters in sync with the resolved theme.
            builder: (context, child) {
              AppColors.brightness = Theme.of(context).brightness;
              return child ?? const SizedBox.shrink();
            },
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
