import 'package:cards/core/storage/storage.dart';
import 'package:cards/models/preferences/preferences.dart';
import 'package:cards/models/preferences/preferences_factory.dart';
import 'package:cards/models/preferences/preferences_json_encoder.dart';

class PreferencesStorageKeys {
  static const mainStorage = "prefs";
  static const testStorage = "prefs-tests";
}

class PreferencesRepository {
  PreferencesRepository({required this.storage, required this.storageKey});

  final Storage storage;
  final String storageKey;
  PreferencesModel _prefs = PreferencesFactory.defaultPrefs();
  PreferencesEncoder encoder = PreferencesEncoder();
  Future<void> save() async {
    await storage.write(key: storageKey, value: encoder.encode(_prefs));
  }

  PreferencesModel get prefs => _prefs;

  void clearStorage() {
    storage.delete(key: storageKey);
  }

  Future<void> readFromStorage() async {
    String? dataJson = await storage.read(key: storageKey);
    if (dataJson == null || dataJson.isEmpty) {
      _prefs = PreferencesFactory.defaultPrefs();
    } else {
      _prefs = encoder.decode(dataJson);
    }
  }

  void setMaskCVV(bool maskCVV) {
    _prefs.setMaskCVV(maskCVV);
  }

  void setMaskCardNumber(bool maskNumber) {
    _prefs.setMaskCardNumber(maskNumber);
  }

  void setEnableNotifications(bool enableNotifications) {
    _prefs.setEnableNotifications(enableNotifications);
  }

  void setUseDeviceAuth(bool useDeviceAuth) {
    _prefs.setUseDeviceAuth(useDeviceAuth);
  }
}
