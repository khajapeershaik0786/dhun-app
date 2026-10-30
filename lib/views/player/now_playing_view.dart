import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/track.dart';
import '../../viewmodels/favourites_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../widgets/artwork.dart';
import 'queue_sheet.dart';

/// Full-screen Spotify-style player.
class NowPlayingView extends StatelessWidget {
  const NowPlayingView({super.key});

  /// Plays [queue] from [index] and opens this screen over everything.
  static Future<void> open(
    BuildContext context,
    List<Track> queue,
    int index, {
    String source = '',
  }) {
    context.read<PlayerViewModel>().playQueue(queue, index, source: source);
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, _, _) => const NowPlayingView(),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerViewModel>();
    final track = player.current;
    if (track == null) {
      return const Scaffold(body: Center(child: Text('Nothing playing')));
    }
    final favs = context.watch<FavouritesViewModel>();
    final liked = favs.isFavourite(track.id);
    final gradient = AppColors.gradientFor(track.id);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradient.first.withValues(alpha: 0.6),
              AppColors.bg,
              AppColors.bg,
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
            child: Column(
              children: [
                _TopBar(
                  source: player.source.isEmpty
                      ? (track.isPodcast ? 'Podcast' : 'dhun')
                      : player.source,
                ),
                const Spacer(flex: 2),
                LayoutBuilder(
                  builder: (context, c) {
                    final s = c.maxWidth.clamp(0, 350).toDouble();
                    return Artwork(
                        url: track.artworkLarge,
                        size: s,
                        seed: track.id,
                        radius: 14);
                  },
                ),
                const Spacer(flex: 2),
                // Title + like.
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(track.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 15)),
                        ],
                      ),
                    ),
                    IconButton(
                      iconSize: 30,
                      onPressed: () => favs.toggle(track),
                      icon: Icon(
                          liked
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: liked ? AppColors.accent : AppColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _SeekBar(player: player),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(player.position),
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                    Text(_fmt(player.duration),
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                _Controls(player: player),
                const SizedBox(height: 14),
                _BottomBar(onQueue: () => showQueueSheet(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.source});
  final String source;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 30),
        ),
        Expanded(
          child: Column(
            children: [
              Text('PLAYING FROM',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(source.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, size: 24),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.player});
  final PlayerViewModel player;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: player.toggleShuffle,
          icon: Icon(Icons.shuffle,
              color:
                  player.shuffle ? AppColors.accent : AppColors.textMuted),
        ),
        IconButton(
          iconSize: 42,
          onPressed: player.hasPrevious ? player.previous : null,
          icon: Icon(Icons.skip_previous,
              color: player.hasPrevious
                  ? AppColors.text
                  : AppColors.textFaint),
        ),
        _BigPlayButton(player: player),
        IconButton(
          iconSize: 42,
          onPressed: player.hasNext ? player.next : null,
          icon: Icon(Icons.skip_next,
              color:
                  player.hasNext ? AppColors.text : AppColors.textFaint),
        ),
        IconButton(
          onPressed: player.cycleRepeat,
          icon: Icon(
            player.repeat == PlayerRepeat.one
                ? Icons.repeat_one
                : Icons.repeat,
            color: player.repeat == PlayerRepeat.off
                ? AppColors.textMuted
                : AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onQueue});
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.devices, size: 20, color: AppColors.textMuted),
        Row(
          children: [
            Icon(Icons.ios_share, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: onQueue,
              child: Icon(Icons.queue_music,
                  size: 22, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar({required this.player});
  final PlayerViewModel player;

  @override
  Widget build(BuildContext context) {
    final total = player.duration.inMilliseconds.toDouble();
    final pos = player.position.inMilliseconds.toDouble().clamp(0, total);
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.text,
        inactiveTrackColor: AppColors.surfaceHigh,
        thumbColor: AppColors.text,
        trackHeight: 4,
      ),
      child: Slider(
        min: 0,
        max: total <= 0 ? 1 : total,
        value: total <= 0 ? 0 : pos.toDouble(),
        onChanged: total <= 0
            ? null
            : (v) => player.seek(Duration(milliseconds: v.round())),
      ),
    );
  }
}

class _BigPlayButton extends StatelessWidget {
  const _BigPlayButton({required this.player});
  final PlayerViewModel player;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration:
          const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
      child: player.isLoading
          ? const Padding(
              padding: EdgeInsets.all(22),
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.onAccent),
            )
          : IconButton(
              onPressed: player.togglePlay,
              icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.onAccent, size: 38),
            ),
    );
  }
}
