import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/track.dart';
import '../../viewmodels/favourites_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import 'artwork.dart';

/// A song/episode row: artwork, title/subtitle, like toggle. Highlights when
/// it is the currently-playing track.
class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.trailingIndex,
  });

  final Track track;
  final VoidCallback onTap;
  final int? trailingIndex;

  @override
  Widget build(BuildContext context) {
    final current = context.select<PlayerViewModel, bool>(
        (p) => p.current?.id == track.id);
    final favs = context.watch<FavouritesViewModel>();
    final liked = favs.isFavourite(track.id);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          children: [
            if (trailingIndex != null) ...[
              SizedBox(
                width: 22,
                child: Text(
                  '$trailingIndex',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textFaint,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Artwork(url: track.artworkUrl, size: 48, seed: track.id),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: current ? AppColors.accent : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (track.isPodcast)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.podcasts,
                              size: 12, color: AppColors.textFaint),
                        ),
                      Flexible(
                        child: Text(
                          track.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (track.duration != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(track.durationLabel,
                    style: const TextStyle(
                        color: AppColors.textFaint, fontSize: 12)),
              ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => favs.toggle(track),
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: liked ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
