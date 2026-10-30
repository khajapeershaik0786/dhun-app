import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../widgets/artwork.dart';

/// Spotify-style "Up next" queue as a draggable bottom sheet.
Future<void> showQueueSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bgElevated,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => const _QueueSheet(),
  );
}

class _QueueSheet extends StatelessWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerViewModel>();
    final queue = player.queue;
    final currentIndex = player.currentIndex;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Text('Up next',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: queue.length,
                itemBuilder: (_, i) {
                  final t = queue[i];
                  final playing = i == currentIndex;
                  return ListTile(
                    onTap: () => player.playAt(i),
                    leading: Artwork(url: t.artworkUrl, size: 46, seed: t.id),
                    title: Text(t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: playing ? AppColors.accent : AppColors.text)),
                    subtitle: Text(t.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                    trailing: playing
                        ? const Icon(Icons.graphic_eq, color: AppColors.accent)
                        : null,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
