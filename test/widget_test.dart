import 'package:flutter_test/flutter_test.dart';

import 'package:dhun/data/models/track.dart';

void main() {
  test('Track parses an iTunes podcast episode', () {
    final t = Track.fromItunes({
      'trackId': 9,
      'trackName': 'Ep 1',
      'collectionName': 'The Daily',
      'artworkUrl100': 'https://x/100x100bb.jpg',
      'episodeUrl': 'https://x/ep.mp3',
      'trackTimeMillis': 268000,
    });

    expect(t, isNotNull);
    expect(t!.isPodcast, isTrue);
    expect(t.streamUrl, 'https://x/ep.mp3');
    expect(t.durationLabel, '4:28');
    expect(t.needsResolve, isFalse);
  });

  test('YouTube track needs resolution and round-trips through JSON', () {
    const a = Track(
      id: 'yt_abc123',
      title: 'Kesariya',
      subtitle: 'Arijit Singh',
      artworkUrl: 'https://img.youtube.com/vi/abc123/hqdefault.jpg',
      streamUrl: '',
      ytId: 'abc123',
      album: 'YouTube',
    );
    expect(a.needsResolve, isTrue);

    final b = Track.fromJson(a.toJson());
    expect(b.id, a.id);
    expect(b.ytId, 'abc123');
    expect(b.needsResolve, isTrue);
  });
}
