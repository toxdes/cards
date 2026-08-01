import 'package:cards/models/preferences/preferences.dart';
import 'package:cards/services/auth_service.dart';

class PreferencesFactory {
  static PreferencesModel defaultPrefs() {
    return PreferencesModel()
      ..setMaskCardNumber(true)
      ..setMaskCVV(true)
      ..setEnableNotifications(true)
      ..setUseDeviceAuth(AuthService.isAuthSupported());
  }

  static PreferencesModel fromSchema(int schemaVersion) {
    return PreferencesModel.fromSchema(schemaVersion);
  }
}
