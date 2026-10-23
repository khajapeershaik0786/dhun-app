import 'package:flutter/foundation.dart';

/// Handles the login form. Navigation is static, so [submit] only validates
/// locally and reports whether the view may proceed to the home shell.
class LoginViewModel extends ChangeNotifier {
  String _identifier = '';
  String _password = '';
  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;
  bool get canSubmit => _identifier.trim().isNotEmpty && _password.isNotEmpty;

  void setIdentifier(String value) {
    _identifier = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void toggleObscure() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool submit() => canSubmit;
}
