import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/track.dart';
import '../../viewmodels/discover_viewmodel.dart';
import '../player/now_playing_view.dart';
import '../widgets/artwork.dart';

/// Tinder-style swipe deck: right = Like, left = Skip, up = Play.
class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  final CardSwiperController _controller = CardSwiperController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiscoverViewModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('Discover',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontSize: 30)),
              const Spacer(),
              const Icon(Icons.swipe, color: AppColors.textMuted, size: 22),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Swipe right to like · left to skip · up to play',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
          ),
        ),
        Expanded(child: _body(context, vm)),
      ],
    );
  }

  Widget _body(BuildContext context, DiscoverViewModel vm) {
    switch (vm.state) {
      case DeckState.loading:
        return const Center(child: CircularProgressIndicator());
      case DeckState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 42, color: AppColors.textFaint),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(vm.error ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted)),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: vm.load,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case DeckState.ready:
        return _deck(context, vm);
    }
  }

  Widget _deck(BuildContext context, DiscoverViewModel vm) {
    final deck = vm.deck;
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: _controller,
            cardsCount: deck.length,
            numberOfCardsDisplayed: math.min(3, deck.length),
            isLoop: true,
            backCardOffset: const Offset(0, 32),
            padding: const EdgeInsets.all(20),
            allowedSwipeDirection:
                const AllowedSwipeDirection.only(left: true, right: true, up: true),
            onSwipe: (prev, current, direction) {
              _handleSwipe(context, vm, deck, prev, direction);
              return true;
            },
            cardBuilder: (context, index, hPct, vPct) =>
                _Card(track: deck[index], hPct: hPct, vPct: vPct),
          ),
        ),
        _actions(),
        const SizedBox(height: 8),
      ],
    );
  }

  void _handleSwipe(BuildContext context, DiscoverViewModel vm,
      List<Track> deck, int prev, CardSwiperDirection direction) {
    final track = deck[prev];
    switch (direction) {
      case CardSwiperDirection.right:
        vm.like(track);
        _snack(context, 'Liked “${track.title}”', AppColors.accent);
        break;
      case CardSwiperDirection.top:
        NowPlayingView.open(context, deck, prev, source: 'Discover');
        break;
      case CardSwiperDirection.left:
      default:
        break;
    }
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
      ));
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.close,
          color: const Color(0xFFEF4444),
          size: 58,
          onTap: () => _controller.swipe(CardSwiperDirection.left),
        ),
        const SizedBox(width: 22),
        _ActionButton(
          icon: Icons.play_arrow_rounded,
          color: AppColors.accent,
          size: 70,
          onTap: () => _controller.swipe(CardSwiperDirection.top),
        ),
        const SizedBox(width: 22),
        _ActionButton(
          icon: Icons.favorite,
          color: const Color(0xFF22C55E),
          size: 58,
          onTap: () => _controller.swipe(CardSwiperDirection.right),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.icon,
      required this.color,
      required this.size,
      required this.onTap});
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.track, required this.hPct, required this.vPct});
  final Track track;
  final int hPct; // -100..100 horizontal drag
  final int vPct; // -100..100 vertical drag

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Artwork(url: track.artworkLarge, size: 1000, seed: track.id, radius: 0),
          // Legibility gradient.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(track.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        height: 1.1)),
                const SizedBox(height: 4),
                Text(track.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),
          // Stamps.
          _Stamp(
            label: 'LIKE',
            color: const Color(0xFF22C55E),
            angle: -0.3,
            alignment: Alignment.topLeft,
            opacity: hPct > 0 ? (hPct / 60).clamp(0.0, 1.0) : 0,
          ),
          _Stamp(
            label: 'NOPE',
            color: const Color(0xFFEF4444),
            angle: 0.3,
            alignment: Alignment.topRight,
            opacity: hPct < 0 ? (-hPct / 60).clamp(0.0, 1.0) : 0,
          ),
          _Stamp(
            label: 'PLAY',
            color: AppColors.accent,
            angle: 0,
            alignment: Alignment.center,
            opacity: vPct < 0 ? (-vPct / 60).clamp(0.0, 1.0) : 0,
          ),
        ],
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.label,
    required this.color,
    required this.angle,
    required this.alignment,
    required this.opacity,
  });
  final String label;
  final Color color;
  final double angle;
  final Alignment alignment;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 34,
                      letterSpacing: 2)),
            ),
          ),
        ),
      ),
    );
  }
}
