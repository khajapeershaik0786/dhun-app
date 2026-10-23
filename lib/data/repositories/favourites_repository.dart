import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track.dart';

/// Stores the user's liked tracks locally (no server) via shared_preferences.
class FavouritesRepository extends ChangeNotifier {
  static const _key = 'dhun.favourites.v1';

  final List<Track> _items = [];
  bool _loaded = false;

  List<Track> get items => List.unmodifiable(_items.reversed);
  int get count => _items.length;
  bool get isLoaded => _loaded;

  bool isFavourite(String id) => _items.any((t) => t.id == id);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? const [];
      _items
        ..clear()
        ..addAll(raw.map((s) => Track.fromJson(
            json.decode(s) as Map<String, dynamic>)));
    } catch (_) {
      // Ignore corrupt/missing storage — start empty.
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(Track track) async {
    final existing = _items.indexWhere((t) => t.id == track.id);
    if (existing >= 0) {
      _items.removeAt(existing);
    } else {
      _items.add(track);
    }
    notifyListeners();
    await _persist();
  }

  /// Add without removing (used by the swipe-to-like gesture).
  Future<void> add(Track track) async {
    if (_items.any((t) => t.id == track.id)) return;
    _items.add(track);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        _items.map((t) => json.encode(t.toJson())).toList(),
      );
    } catch (_) {
      // Best-effort; in-memory state still reflects the change.
    }
  }
}
