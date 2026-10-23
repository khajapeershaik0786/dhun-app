import '../models/track.dart';
import '../services/audius_api.dart';
import '../services/itunes_api.dart';

/// A named, lazily-loaded shelf of tracks shown on Home (Spotify/Saavn rails).
class Shelf {
  Shelf({required this.title, required this.tracks});
  final String title;
  final List<Track> tracks;
}

/// Full-length songs come from Audius; podcasts from iTunes (both keyless).
class CatalogRepository {
  CatalogRepository(this._audius, this._itunes);

  final AudiusApi _audius;
  final ItunesApi _itunes;

  /// Search used by the Search screen.
  Future<List<Track>> search(String term, {bool podcasts = false}) =>
      podcasts ? _itunes.searchPodcasts(term) : _audius.searchSongs(term);

  /// A shuffled trending deck for the Discover (swipe) screen.
  Future<List<Track>> discoverDeck({int limit = 30}) async {
    final tracks = await _audius.trending(limit: limit);
    tracks.shuffle();
    return tracks;
  }

  /// Curated Home rails: Audius trending by genre + a podcast shelf.
  static const _rails = <MapEntry<String, String?>>[
    MapEntry('Trending now', null),
    MapEntry('Electronic', 'Electronic'),
    MapEntry('Hip-Hop', 'Hip-Hop/Rap'),
    MapEntry('Lo-Fi & chill', 'Lo-Fi'),
    MapEntry('Pop', 'Pop'),
  ];

  Future<List<Shelf>> loadHome() async {
    final songFutures = _rails.map((e) async {
      final tracks = await _audius.trending(genre: e.value, limit: 15);
      return Shelf(title: e.key, tracks: tracks);
    });
    final podcastShelf = _itunes.searchPodcasts('news', limit: 12).then(
          (t) => Shelf(title: 'Podcasts for you', tracks: t),
        );
    final shelves = await Future.wait([...songFutures, podcastShelf]);
    return shelves.where((s) => s.tracks.isNotEmpty).toList();
  }
}
