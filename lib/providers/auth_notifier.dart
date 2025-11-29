import 'package:cards/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthNotifier extends ChangeNotifier {
  bool _authenticated = false;
  bool _isAuthInProgress = false;

  bool needsAuth(bool deviceAuthEnabled) {
    return deviceAuthEnabled &&
        AuthService.isAuthSupported() &&
        !_authenticated;
  }

  bool isAuthInProgress() {
    return _isAuthInProgress;
  }

  Future<bool> authenticate() async {
    if (!AuthService.isAuthSupported()) return false;
    if (_isAuthInProgress) return false;
    if (_authenticated) return _authenticated;

    _isAuthInProgress = true;
    notifyListeners();
    _authenticated = await AuthService.authenticate();
    _isAuthInProgress = false;
    notifyListeners();
    return _authenticated;
  }
}
