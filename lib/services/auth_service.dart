import 'package:cards/services/platform_service.dart';
import 'package:cards/services/sentry_service.dart';
import 'package:local_auth/local_auth.dart';

class AuthServiceErrorCodes {
  static const int calledWithoutInit = 0x101;
}

class AuthServiceException implements Exception {
  final String message;
  final int errorCode;
  AuthServiceException(this.errorCode, this.message);
  @override
  String toString() {
    return '[AuthServiceException] Error $errorCode: $message';
  }
}

class AuthService {
  static bool _isAuthSupported = false;
  static bool _initialized = false;
  static LocalAuthentication? _auth;

  static Future<void> init() async {
    _auth = LocalAuthentication();
    _isAuthSupported = !PlatformService.isLinux() &&
        !PlatformService.isWeb() &&
        await _auth!.isDeviceSupported();
    _initialized = true;
    if (!_isAuthSupported) return;
  }

  static void _requireInit() {
    if (!_initialized) {
      throw AuthServiceException(
          AuthServiceErrorCodes.calledWithoutInit, "called without init()");
    }
  }

  static bool isAuthSupported() {
    _requireInit();
    return _isAuthSupported;
  }

  static Future<bool> authenticate() async {
    _requireInit();
    try {
      return await _auth!.authenticate(localizedReason: "Unlock");
    } catch (e, stackTrace) {
      SentryService.error(e, stackTrace);
      // TODO: show toast here based on what error we get?
    }
    return false;
  }
}
