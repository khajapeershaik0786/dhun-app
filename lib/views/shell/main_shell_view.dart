import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../discover/discover_view.dart';
import '../favourites/favourites_view.dart';
import '../home/home_view.dart';
import '../search/search_view.dart';
import 'widgets/mini_player.dart';

/// Hosts the four tabs behind a persistent bottom nav + mini player.
class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeView(),
    SearchView(),
    DiscoverView(),
    FavouritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    // Depend on Theme so the shell (background + nav) rebuilds on theme change.
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _tabs),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(),
          NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppColors.bgElevated,
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.text : AppColors.textMuted,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                    color: selected ? AppColors.accent : AppColors.textMuted);
              }),
            ),
            child: NavigationBar(
              height: 62,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.search), label: 'Search'),
                NavigationDestination(
                    icon: Icon(Icons.style_outlined),
                    selectedIcon: Icon(Icons.style),
                    label: 'Discover'),
                NavigationDestination(
                    icon: Icon(Icons.favorite_border),
                    selectedIcon: Icon(Icons.favorite),
                    label: 'Likes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
