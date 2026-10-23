import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/player_viewmodel.dart';
import '../../player/now_playing_view.dart';
import '../../widgets/artwork.dart';

/// Compact now-playing strip shown above the bottom nav. Hidden when idle.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerViewModel>();
    final track = player.current;
    if (track == null) return const SizedBox.shrink();

    final gradient = AppColors.gradientFor(track.id);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NowPlayingView()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [gradient.first.withValues(alpha: 0.85), AppColors.surfaceHigh],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Artwork(url: track.artworkUrl, size: 44, seed: track.id),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: Colors.white)),
                      Text(track.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5, color: Color(0xFFE6E6EA))),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: player.previous,
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                ),
                _PlayButton(player: player),
                IconButton(
                  onPressed: player.hasNext ? player.next : null,
                  icon: Icon(Icons.skip_next,
                      color: player.hasNext ? Colors.white : Colors.white38),
                ),
              ],
            ),
            // Progress line.
            LinearProgressIndicator(
              value: player.progress == 0 ? null : player.progress,
              minHeight: 2,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.player});
  final PlayerViewModel player;

  @override
  Widget build(BuildContext context) {
    if (player.isLoading) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white),
          ),
        ),
      );
    }
    return IconButton(
      onPressed: player.togglePlay,
      icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white, size: 28),
    );
  }
}
