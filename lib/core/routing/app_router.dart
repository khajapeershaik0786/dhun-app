import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/favourites_repository.dart';
import '../../viewmodels/discover_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/signup_view.dart';
import '../../views/profile/profile_view.dart';
import '../../views/settings/settings_view.dart';
import '../../views/shell/main_shell_view.dart';
import '../../views/splash/splash_view.dart';
import 'app_routes.dart';

/// Resolves named routes, scoping per-screen ViewModels where needed.
/// App-wide ViewModels (player, favourites) live above this in [DhunApp].
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashView(), settings);

      case AppRoutes.login:
        return _page(
          ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const LoginView(),
          ),
          settings,
        );

      case AppRoutes.signup:
        return _page(
          ChangeNotifierProvider(
            create: (_) => SignupViewModel(),
            child: const SignupView(),
          ),
          settings,
        );

      case AppRoutes.home:
        return _page(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (ctx) => HomeViewModel(ctx.read<CatalogRepository>()),
              ),
              ChangeNotifierProvider(
                create: (ctx) => SearchViewModel(ctx.read<CatalogRepository>()),
              ),
              ChangeNotifierProvider(
                create: (ctx) => DiscoverViewModel(
                    ctx.read<CatalogRepository>(),
                    ctx.read<FavouritesRepository>()),
              ),
            ],
            child: const MainShellView(),
          ),
          settings,
        );

      case AppRoutes.settings:
        return _page(const SettingsView(), settings);

      case AppRoutes.profile:
        return _page(const ProfileView(), settings);

      default:
        return _page(const SplashView(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) =>
      MaterialPageRoute<dynamic>(builder: (_) => child, settings: settings);
}
