import 'package:cards/models/preferences/preferences.dart';
import 'package:cards/repositories/preferences_repository.dart';
import 'package:cards/utils/secure_storage.dart';
import 'package:flutter/foundation.dart';

class PreferencesNotifier extends ChangeNotifier {
  final PreferencesRepository _prefsRepo;
  bool _loaded = false;

  PreferencesNotifier({PreferencesRepository? repository})
      : _prefsRepo = repository ??
            PreferencesRepository(
                storageKey: PreferencesStorageKeys.mainStorage,
                storage: const SecureStorage()) {
    _initPrefs();
  }

  void _initPrefs() {
    _prefsRepo.readFromStorage().then((_) {
      _loaded = true;
      notifyListeners();
    }).catchError((e) {
      _loaded = false;
      notifyListeners();
    });
  }

  bool get isLoaded => _loaded;

  PreferencesModel get prefs => _prefsRepo.prefs;

  void setMaskCVV(bool maskCVV) {
    _prefsRepo.setMaskCVV(maskCVV);
    _prefsRepo.save();
    notifyListeners();
  }

  void setMaskCardNumber(bool maskNumber) {
    _prefsRepo.setMaskCardNumber(maskNumber);
    _prefsRepo.save();
    notifyListeners();
  }

  void setEnableNotifications(bool enableNotifications) {
    _prefsRepo.setEnableNotifications(enableNotifications);
    _prefsRepo.save();
    notifyListeners();
  }

  void setUseDeviceAuth(bool useDeviceAuth) {
    _prefsRepo.setUseDeviceAuth(useDeviceAuth);
    _prefsRepo.save();
    notifyListeners();
  }
}
