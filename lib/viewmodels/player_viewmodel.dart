import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/models/track.dart';

enum PlayerRepeat { off, all, one }

/// Resolves a playable audio URL for a track (YouTube streams are resolved
/// lazily; direct URLs pass through).
typedef StreamResolver = Future<String?> Function(Track track);

/// App-wide playback controller. Owns a single [AudioPlayer] and an in-memory
/// queue, exposing state for the mini player and the full now-playing screen.
class PlayerViewModel extends ChangeNotifier {
  PlayerViewModel({required StreamResolver resolver}) : _resolve = resolver {
    _player.playerStateStream.listen(_onPlayerState);
    _player.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
    _player.durationStream.listen((d) {
      if (d != null) {
        _duration = d;
        notifyListeners();
      }
    });
    _player.bufferedPositionStream.listen((b) {
      _buffered = b;
      notifyListeners();
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final Random _rng = Random();
  final StreamResolver _resolve;
  int _loadToken = 0;

  List<Track> _queue = const [];
  int _index = -1;
  String _source = '';

  Duration _position = Duration.zero;
  Duration _buffered = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = false;
  String? _error;
  bool _shuffle = false;
  PlayerRepeat _repeat = PlayerRepeat.off;

  // ── exposed state ──────────────────────────────────────────────
  List<Track> get queue => _queue;
  int get currentIndex => _index;
  String get source => _source;
  Track? get current =>
      (_index >= 0 && _index < _queue.length) ? _queue[_index] : null;
  bool get hasTrack => current != null;
  bool get isPlaying => _player.playing;
  bool get isLoading => _loading;
  String? get error => _error;
  Duration get position => _position;
  Duration get buffered => _buffered;
  Duration get duration => _duration == Duration.zero
      ? (current?.duration ?? Duration.zero)
      : _duration;
  bool get shuffle => _shuffle;
  PlayerRepeat get repeat => _repeat;

  bool get hasPrevious => _index > 0;
  bool get hasNext =>
      _shuffle || _repeat == PlayerRepeat.all || _index < _queue.length - 1;

  double get progress {
    final total = duration.inMilliseconds;
    if (total <= 0) return 0;
    return (_position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  void _onPlayerState(PlayerState state) {
    _loading = state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering;
    if (state.processingState == ProcessingState.completed) {
      if (_repeat == PlayerRepeat.one) {
        _loadIndex(_index);
      } else {
        _advance(auto: true);
      }
    }
    notifyListeners();
  }

  // ── commands ───────────────────────────────────────────────────
  Future<void> playQueue(List<Track> tracks, int startIndex,
      {String source = ''}) async {
    _queue = List.unmodifiable(tracks);
    _source = source;
    await _loadIndex(startIndex);
  }

  Future<void> playSingle(Track track, {String source = ''}) =>
      playQueue([track], 0, source: source);

  Future<void> playAt(int index) => _loadIndex(index);

  Future<void> _loadIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    final token = ++_loadToken;
    _index = index;
    _error = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _loading = true;
    notifyListeners();
    try {
      final track = _queue[index];
      final url = await _resolve(track);
      if (token != _loadToken) return; // superseded by a newer request
      if (url == null || url.isEmpty) {
        _error = 'This track is unavailable';
        _loading = false;
        notifyListeners();
        return;
      }
      await _player.setUrl(url);
      if (token != _loadToken) return;
      await _player.play();
    } catch (e) {
      if (token != _loadToken) return;
      _error = 'Could not play this track';
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> next() => _advance();

  Future<void> _advance({bool auto = false}) async {
    if (_queue.isEmpty) return;
    if (_shuffle && _queue.length > 1) {
      int n;
      do {
        n = _rng.nextInt(_queue.length);
      } while (n == _index);
      await _loadIndex(n);
    } else if (_index < _queue.length - 1) {
      await _loadIndex(_index + 1);
    } else if (_repeat == PlayerRepeat.all) {
      await _loadIndex(0);
    } else if (auto) {
      await _player.pause();
      await _player.seek(Duration.zero);
      notifyListeners();
    }
  }

  Future<void> previous() async {
    if (_position > const Duration(seconds: 3) || !hasPrevious) {
      await _player.seek(Duration.zero);
    } else {
      await _loadIndex(_index - 1);
    }
  }

  Future<void> seek(Duration to) => _player.seek(to);

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void cycleRepeat() {
    _repeat = PlayerRepeat.values[(_repeat.index + 1) % PlayerRepeat.values.length];
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
