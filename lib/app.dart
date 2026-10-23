import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/favourites_repository.dart';
import 'data/services/audius_api.dart';
import 'data/services/itunes_api.dart';
import 'viewmodels/favourites_viewmodel.dart';
import 'viewmodels/player_viewmodel.dart';

/// Root widget. Wires app-wide services, repositories and the player, then
/// installs the dark theme + static route table.
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
      child: MaterialApp(
        title: 'dhun',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
