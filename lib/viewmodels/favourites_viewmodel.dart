import 'package:flutter/foundation.dart';

import '../data/models/track.dart';
import '../data/repositories/favourites_repository.dart';

/// View state for the Favourites screen.
class FavouritesViewModel extends ChangeNotifier {
  FavouritesViewModel(this._repo) {
    _repo.addListener(notifyListeners);
    if (!_repo.isLoaded) _repo.load();
  }

  final FavouritesRepository _repo;

  List<Track> get tracks => _repo.items;
  int get count => _repo.count;
  bool get isEmpty => _repo.count == 0;

  bool isFavourite(String id) => _repo.isFavourite(id);
  Future<void> toggle(Track t) => _repo.toggle(t);

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    super.dispose();
  }
}
