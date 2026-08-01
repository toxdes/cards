import 'package:cards/models/preferences/preferences.dart';

class PreferencesFactory {
  static PreferencesModel defaultPrefs() {
    return PreferencesModel()
      ..setMaskCardNumber(true)
      ..setMaskCVV(true)
      ..setEnableNotifications(true)
      ..setUseDeviceAuth(true);
  }

  static PreferencesModel fromSchema(int schemaVersion) {
    return PreferencesModel.fromSchema(schemaVersion);
  }
}
