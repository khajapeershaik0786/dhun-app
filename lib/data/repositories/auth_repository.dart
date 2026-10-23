import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists a simple logged-in session locally so the user stays signed in
/// across app restarts (no backend / real auth in this build).
class AuthRepository extends ChangeNotifier {
  static const _keyLoggedIn = 'dhun.auth.loggedIn';
  static const _keyName = 'dhun.auth.name';

  bool _loaded = false;
  bool _loggedIn = false;
  String? _displayName;

  bool get isLoaded => _loaded;
  bool get isLoggedIn => _loggedIn;
  String? get displayName => _displayName;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _loggedIn = prefs.getBool(_keyLoggedIn) ?? false;
      _displayName = prefs.getString(_keyName);
    } catch (_) {
      _loggedIn = false;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> logIn({String? name}) async {
    _loggedIn = true;
    _displayName = name;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoggedIn, true);
      if (name != null) await prefs.setString(_keyName, name);
    } catch (_) {/* best effort */}
  }

  Future<void> logOut() async {
    _loggedIn = false;
    _displayName = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLoggedIn);
      await prefs.remove(_keyName);
    } catch (_) {/* best effort */}
  }
}
