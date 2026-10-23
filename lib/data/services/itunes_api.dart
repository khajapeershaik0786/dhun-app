import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/track.dart';

/// Thin client over Apple's public iTunes Search API — keyless, no backend.
///
/// Songs come back as 30-second preview streams (`previewUrl`); podcast
/// episodes come back as full-length audio (`episodeUrl`). Both are free and
/// legal to stream.
class ItunesApi {
  ItunesApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _base = 'https://itunes.apple.com/search';

  /// Search songs (music previews).
  Future<List<Track>> searchSongs(String term, {int limit = 40}) {
    return _search({
      'term': term,
      'media': 'music',
      'entity': 'song',
      'limit': '$limit',
    });
  }

  /// Search podcast episodes (full audio).
  Future<List<Track>> searchPodcasts(String term, {int limit = 30}) {
    return _search({
      'term': term,
      'media': 'podcast',
      'entity': 'podcastEpisode',
      'limit': '$limit',
    });
  }

  Future<List<Track>> _search(Map<String, String> params) async {
    final uri = Uri.parse(_base).replace(queryParameters: params);
    final res = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('iTunes search failed (${res.statusCode})');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final results = (body['results'] as List?) ?? const [];
    final tracks = <Track>[];
    final seen = <String>{};
    for (final r in results) {
      final t = Track.fromItunes(r as Map<String, dynamic>);
      if (t != null && seen.add(t.id)) tracks.add(t);
    }
    return tracks;
  }

  void dispose() => _client.close();
}
