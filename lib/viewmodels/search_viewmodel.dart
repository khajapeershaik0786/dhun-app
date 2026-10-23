import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/track.dart';
import '../data/repositories/catalog_repository.dart';

enum SearchState { empty, loading, results, noResults, error }

/// Debounced search over songs or podcasts.
class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._catalog);

  final CatalogRepository _catalog;

  Timer? _debounce;
  int _requestId = 0;

  String _query = '';
  bool _podcasts = false;
  SearchState _state = SearchState.empty;
  List<Track> _results = const [];

  final List<String> chips = const [
    'Arijit Singh',
    'Lo-fi',
    'Punjabi',
    'Tamil hits',
    'Workout',
    '90s',
  ];

  String get query => _query;
  bool get podcasts => _podcasts;
  SearchState get state => _state;
  List<Track> get results => _results;

  void setPodcasts(bool value) {
    if (_podcasts == value) return;
    _podcasts = value;
    if (_query.trim().isNotEmpty) _run(_query);
    notifyListeners();
  }

  void onChanged(String value) {
    _query = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      _state = SearchState.empty;
      _results = const [];
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _run(value));
  }

  void submit(String value) {
    _query = value;
    _debounce?.cancel();
    _run(value);
  }

  Future<void> _run(String term) async {
    final id = ++_requestId;
    _state = SearchState.loading;
    notifyListeners();
    try {
      final res = await _catalog.search(term.trim(), podcasts: _podcasts);
      if (id != _requestId) return; // stale
      _results = res;
      _state = res.isEmpty ? SearchState.noResults : SearchState.results;
    } catch (e) {
      if (id != _requestId) return;
      _state = SearchState.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
