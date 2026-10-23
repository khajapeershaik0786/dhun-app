import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/track.dart';

/// Client for the Audius public API — keyless, no backend. Serves **full
/// length** tracks (independent artists). Stream URLs are direct and ready to
/// play (no per-track resolution needed).
///
/// Uses official discovery nodes directly: the `api.audius.co` gateway proxies
/// search/metadata but not the `/stream` endpoint, so a real node is required.
class AudiusApi {
  AudiusApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _appName = 'dhun';

  /// Official Audius discovery nodes (all support `/v1/tracks/.../stream`).
  static const _hosts = [
    'https://discoveryprovider.audius.co',
    'https://discoveryprovider2.audius.co',
    'https://discoveryprovider3.audius.co',
  ];
  int _hostIndex = 0;
  String get _host => _hosts[_hostIndex];

  Future<List<Track>> searchSongs(String term, {int limit = 30}) {
    return _fetch('/v1/tracks/search', {'query': term, 'limit': '$limit'});
  }

  Future<List<Track>> trending({String? genre, int limit = 20}) {
    final params = {'limit': '$limit'};
    if (genre != null) params['genre'] = genre;
    return _fetch('/v1/tracks/trending', params);
  }

  Future<List<Track>> _fetch(String path, Map<String, String> params) async {
    final query = {...params, 'app_name': _appName};
    // Try each host until one responds, remembering the working one.
    for (var attempt = 0; attempt < _hosts.length; attempt++) {
      final host = _host;
      try {
        final uri = Uri.parse('$host$path').replace(queryParameters: query);
        final res =
            await _client.get(uri).timeout(const Duration(seconds: 15));
        if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
        final body = json.decode(res.body) as Map<String, dynamic>;
        final list = (body['data'] as List?) ?? const [];
        final tracks = <Track>[];
        for (final t in list) {
          final track = _toTrack(t as Map<String, dynamic>, host);
          if (track != null) tracks.add(track);
        }
        return tracks;
      } catch (e) {
        debugPrint('DHUN: audius host $host failed -> $e');
        _hostIndex = (_hostIndex + 1) % _hosts.length; // rotate and retry
      }
    }
    return const [];
  }

  Track? _toTrack(Map<String, dynamic> j, String host) {
    final id = j['id']?.toString();
    if (id == null) return null;
    if (j['is_streamable'] == false) return null;
    // Skip gated / premium tracks that won't stream anonymously.
    if (j['is_premium'] == true || j['stream_conditions'] != null) return null;

    final art = j['artwork'] as Map<String, dynamic>?;
    final secs = j['duration'];
    return Track(
      id: 'au_$id',
      title: (j['title'] ?? 'Unknown').toString(),
      subtitle: (j['user']?['name'] ?? 'Unknown artist').toString(),
      album: (j['genre'] ?? 'Audius').toString(),
      artworkUrl: (art?['150x150'] ?? '') as String,
      artworkHd: (art?['480x480'] ?? art?['1000x1000']) as String?,
      streamUrl: '$host/v1/tracks/$id/stream?app_name=$_appName',
      duration: secs is int ? Duration(seconds: secs) : null,
    );
  }

  void dispose() => _client.close();
}
