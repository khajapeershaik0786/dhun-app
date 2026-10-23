import 'package:flutter/foundation.dart';

import '../data/models/track.dart';
import '../data/repositories/catalog_repository.dart';

enum LoadState { idle, loading, ready, error }

/// Loads the Home feed (curated rails) from the catalog.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._catalog) {
    load();
  }

  final CatalogRepository _catalog;

  LoadState _state = LoadState.idle;
  List<Shelf> _shelves = const [];
  String? _error;

  LoadState get state => _state;
  List<Shelf> get shelves => _shelves;
  String? get error => _error;

  /// A flat queue (all shelf tracks) so tapping a card can play through.
  List<Track> get allTracks =>
      [for (final s in _shelves) ...s.tracks];

  int indexOf(Track track) => allTracks.indexOf(track);

  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _shelves = await _catalog.loadHome();
      _state = _shelves.isEmpty ? LoadState.error : LoadState.ready;
      if (_shelves.isEmpty) _error = 'No results. Check your connection.';
    } catch (e) {
      _state = LoadState.error;
      _error = 'Couldn\'t load music. Check your connection.';
    }
    notifyListeners();
  }
}
