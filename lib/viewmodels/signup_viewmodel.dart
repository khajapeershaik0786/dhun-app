import 'package:flutter/foundation.dart';

/// Drives the two-step sign-up flow: profile details, then language picks.
class SignupViewModel extends ChangeNotifier {
  String _name = '';
  String _mobile = '';
  String _password = '';

  final List<String> languages = const [
    'Hindi',
    'Telugu',
    'Tamil',
    'Punjabi',
    'English',
  ];
  final Set<String> _selectedLanguages = {'Hindi', 'Telugu'};

  Set<String> get selectedLanguages => _selectedLanguages;

  bool isLanguageSelected(String lang) => _selectedLanguages.contains(lang);

  bool get canSubmit =>
      _name.trim().isNotEmpty &&
      _mobile.trim().isNotEmpty &&
      _password.length >= 8 &&
      _selectedLanguages.isNotEmpty;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setMobile(String value) {
    _mobile = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void toggleLanguage(String lang) {
    if (!_selectedLanguages.remove(lang)) {
      _selectedLanguages.add(lang);
    }
    notifyListeners();
  }

  bool submit() => canSubmit;
}
