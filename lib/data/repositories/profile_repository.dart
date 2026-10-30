import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user's profile locally (name, optional photo). The photo is
/// copied into the app's documents directory so it survives restarts.
class ProfileRepository extends ChangeNotifier {
  static const _kFirst = 'dhun.profile.first';
  static const _kLast = 'dhun.profile.last';
  static const _kEmail = 'dhun.profile.email';
  static const _kPhoto = 'dhun.profile.photo';

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String? _photoPath;
  bool _loaded = false;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String? get photoPath => _photoPath;
  bool get isLoaded => _loaded;

  String get fullName {
    final name = '$_firstName $_lastName'.trim();
    return name.isEmpty ? 'dhun listener' : name;
  }

  /// Initials for the fallback avatar when no photo is set.
  String get initials {
    final f = _firstName.trim();
    final l = _lastName.trim();
    if (f.isEmpty && l.isEmpty) return 'DH';
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : (f.length > 1 ? f[1] : '');
    return (a + b).toUpperCase();
  }

  File? get photoFile {
    final p = _photoPath;
    if (p == null) return null;
    final f = File(p);
    return f.existsSync() ? f : null;
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _firstName = prefs.getString(_kFirst) ?? '';
      _lastName = prefs.getString(_kLast) ?? '';
      _email = prefs.getString(_kEmail) ?? '';
      _photoPath = prefs.getString(_kPhoto);
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveDetails({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kFirst, firstName);
      await prefs.setString(_kLast, lastName);
      await prefs.setString(_kEmail, email);
    } catch (_) {/* best effort */}
  }

  /// Copies [sourcePath] into app storage and sets it as the profile photo.
  Future<void> setPhoto(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
      final dest =
          '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(sourcePath).copy(dest);
      // Remove the previous photo to avoid clutter.
      final old = _photoPath;
      _photoPath = dest;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPhoto, dest);
      if (old != null && old != dest) {
        final f = File(old);
        if (f.existsSync()) await f.delete();
      }
    } catch (_) {/* keep previous photo on failure */}
  }

  Future<void> removePhoto() async {
    final old = _photoPath;
    _photoPath = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPhoto);
      if (old != null) {
        final f = File(old);
        if (f.existsSync()) await f.delete();
      }
    } catch (_) {/* best effort */}
  }

  /// Seeds name/email at sign-up if not already set.
  Future<void> seedIfEmpty({String? name, String? email}) async {
    if (_firstName.isNotEmpty || _lastName.isNotEmpty) return;
    final parts = (name ?? '').trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    await saveDetails(
        firstName: first, lastName: last, email: email ?? _email);
  }
}
