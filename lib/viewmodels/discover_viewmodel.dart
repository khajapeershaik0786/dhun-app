import 'package:flutter/foundation.dart';

import '../data/models/track.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/favourites_repository.dart';

enum DeckState { loading, ready, error }

/// Supplies a deck of tracks for the Tinder-style Discover screen and relays
/// like / skip actions.
class DiscoverViewModel extends ChangeNotifier {
  DiscoverViewModel(this._catalog, this._favourites) {
    load();
  }

  final CatalogRepository _catalog;
  final FavouritesRepository _favourites;

  DeckState _state = DeckState.loading;
  List<Track> _deck = const [];
  String? _error;

  DeckState get state => _state;
  List<Track> get deck => _deck;
  String? get error => _error;

  Future<void> load() async {
    _state = DeckState.loading;
    notifyListeners();
    try {
      _deck = await _catalog.discoverDeck();
      _state = _deck.length < 2 ? DeckState.error : DeckState.ready;
      if (_deck.length < 2) _error = 'Not enough tracks to discover right now.';
    } catch (e) {
      _state = DeckState.error;
      _error = 'Couldn\'t load Discover. Check your connection.';
    }
    notifyListeners();
  }

  bool isLiked(String id) => _favourites.isFavourite(id);

  Future<void> like(Track track) => _favourites.add(track);
}
