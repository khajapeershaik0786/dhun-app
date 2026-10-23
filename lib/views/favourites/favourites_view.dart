import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../viewmodels/favourites_viewmodel.dart';
import '../player/now_playing_view.dart';
import '../widgets/track_tile.dart';

/// Liked songs & episodes (persisted locally).
class FavouritesView extends StatelessWidget {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavouritesViewModel>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.heroGradient,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text('Your Likes',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontSize: 32, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${vm.count} ${vm.count == 1 ? 'track' : 'tracks'} · Only you',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ),
        if (!vm.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'fav-play',
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    elevation: 0,
                    onPressed: () => NowPlayingView.open(context, vm.tracks, 0,
                        source: 'Your Likes'),
                    child: const Icon(Icons.play_arrow, size: 30),
                  ),
                ],
              ),
            ),
          ),
        if (vm.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border,
                        size: 44, color: AppColors.textFaint),
                    SizedBox(height: 12),
                    Text('Songs you like will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: vm.tracks.length,
            itemBuilder: (_, i) => TrackTile(
              track: vm.tracks[i],
              onTap: () => NowPlayingView.open(context, vm.tracks, i,
                  source: 'Your Likes'),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
      ],
    );
  }
}
