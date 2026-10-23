/// A playable item — a song (YouTube), or a podcast episode (iTunes).
///
/// For YouTube tracks the audio URL is not known up front: [ytId] is set and
/// [streamUrl] is empty until the player resolves it on demand. For podcasts,
/// [streamUrl] is a direct, ready-to-play URL.
class Track {
  const Track({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.artworkUrl,
    required this.streamUrl,
    this.artworkHd,
    this.album,
    this.duration,
    this.isPodcast = false,
    this.ytId,
  });

  final String id;
  final String title;
  final String subtitle; // artist (song) or show name (podcast)
  final String? album;
  final String artworkUrl;
  final String? artworkHd;
  final String streamUrl;
  final Duration? duration;
  final bool isPodcast;

  /// YouTube video id; when set, the stream must be resolved before playback.
  final String? ytId;

  bool get needsResolve => ytId != null;

  /// Higher-resolution artwork for the full player.
  String get artworkLarge =>
      artworkHd ?? artworkUrl.replaceAll('100x100bb', '600x600bb');

  String get durationLabel {
    final d = duration;
    if (d == null) return '';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'album': album,
        'artworkUrl': artworkUrl,
        'artworkHd': artworkHd,
        'streamUrl': streamUrl,
        'durationMs': duration?.inMilliseconds,
        'isPodcast': isPodcast,
        'ytId': ytId,
      };

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        album: json['album'] as String?,
        artworkUrl: json['artworkUrl'] as String,
        artworkHd: json['artworkHd'] as String?,
        streamUrl: json['streamUrl'] as String,
        duration: json['durationMs'] == null
            ? null
            : Duration(milliseconds: json['durationMs'] as int),
        isPodcast: json['isPodcast'] as bool? ?? false,
        ytId: json['ytId'] as String?,
      );

  /// Builds a podcast [Track] from an iTunes Search API result entry.
  static Track? fromItunes(Map<String, dynamic> j) {
    final stream = (j['episodeUrl'] ?? j['previewUrl']) as String?;
    if (stream == null || stream.isEmpty) return null;

    final art = (j['artworkUrl100'] ?? j['artworkUrl60'] ?? '') as String;
    final ms = j['trackTimeMillis'];

    return Track(
      id: (j['trackId'] ?? j['episodeGuid'] ?? stream).toString(),
      title: (j['trackName'] ?? j['collectionName'] ?? 'Unknown').toString(),
      subtitle: (j['artistName'] ?? j['collectionName'] ?? '').toString(),
      album: j['collectionName']?.toString(),
      artworkUrl: art,
      streamUrl: stream,
      duration: ms is int ? Duration(milliseconds: ms) : null,
      isPodcast: true,
    );
  }

  @override
  bool operator ==(Object other) => other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
