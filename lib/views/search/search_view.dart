import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../player/now_playing_view.dart';
import '../widgets/track_tile.dart';

/// Search songs & podcasts and play results.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Search',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontSize: 30)),
          ),
        ),
        // Search field.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onChanged: vm.onChanged,
            onSubmitted: vm.submit,
            style: TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Songs, artists, podcasts…',
              hintStyle: TextStyle(color: AppColors.textFaint),
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () {
                        _controller.clear();
                        vm.onChanged('');
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: AppColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Songs / Podcasts toggle.
        Row(
          children: [
            const SizedBox(width: 16),
            _Segment(
                label: 'Songs',
                selected: !vm.podcasts,
                onTap: () => vm.setPodcasts(false)),
            const SizedBox(width: 8),
            _Segment(
                label: 'Podcasts',
                selected: vm.podcasts,
                onTap: () => vm.setPodcasts(true)),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(child: _Body(vm: vm, controller: _controller)),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.vm, required this.controller});
  final SearchViewModel vm;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    switch (vm.state) {
      case SearchState.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchState.error:
        return const _Centered(
            icon: Icons.wifi_off_rounded, text: 'Search failed. Try again.');
      case SearchState.noResults:
        return _Centered(
            icon: Icons.search_off, text: 'No results for “${vm.query}”.');
      case SearchState.empty:
        return _Suggestions(vm: vm, controller: controller);
      case SearchState.results:
        return ListView.builder(
          itemCount: vm.results.length,
          itemBuilder: (_, i) {
            final t = vm.results[i];
            return TrackTile(
              track: t,
              onTap: () => NowPlayingView.open(context, vm.results, i,
                  source: 'Search'),
            );
          },
        );
    }
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.vm, required this.controller});
  final SearchViewModel vm;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      children: [
        Text('Try searching',
            style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: vm.chips.map((c) {
            return ActionChip(
              label: Text(c),
              backgroundColor: AppColors.surface,
              side: BorderSide.none,
              labelStyle: TextStyle(color: AppColors.text),
              onPressed: () {
                controller.text = c;
                vm.submit(c);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.onAccent : AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppColors.textFaint),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}
