import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/track.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../player/now_playing_view.dart';
import '../widgets/artwork.dart';

/// Home feed — greeting + horizontal rails of real tracks.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(_greeting,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 24)),
                ),
                const Icon(Icons.notifications_none, size: 24),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.settings),
                  child: const Icon(Icons.settings_outlined, size: 24),
                ),
              ],
            ),
          ),
        ),
        if (vm.state == LoadState.loading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (vm.state == LoadState.error)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorState(message: vm.error ?? 'Something went wrong',
                onRetry: vm.load),
          )
        else ...[
          SliverList.builder(
            itemCount: vm.shelves.length,
            itemBuilder: (_, i) => _Rail(shelf: vm.shelves[i], home: vm),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.shelf, required this.home});
  final Shelf shelf;
  final HomeViewModel home;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
          child: Text(shelf.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 19)),
        ),
        SizedBox(
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shelf.tracks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) =>
                _Card(track: shelf.tracks[i], home: home, source: shelf.title),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.track, required this.home, required this.source});
  final Track track;
  final HomeViewModel home;
  final String source;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: () => NowPlayingView.open(
            context, home.allTracks, home.indexOf(track),
            source: source),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Artwork(url: track.artworkLarge, size: 150, seed: track.id, radius: 8),
            const SizedBox(height: 8),
            Text(track.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.2)),
            const SizedBox(height: 2),
            Text(track.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.textFaint),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
