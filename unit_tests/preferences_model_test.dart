import 'package:cards/models/preferences/preferences.dart';
import 'package:test/test.dart';

void main() {
  test('constructor initializes with default values', () {
    PreferencesModel prefs = PreferencesModel();
    assert(prefs.maskCardNumber == true);
    assert(prefs.maskCVV == true);
    assert(prefs.enableNotifications == true);
    assert(prefs.useDeviceAuth == true);
    assert(prefs.schemaVersion == 1);
  });

  test('fromSchema constructor initializes with default values', () {
    PreferencesModel prefs = PreferencesModel.fromSchema(1);
    assert(prefs.maskCardNumber == true);
    assert(prefs.maskCVV == true);
    assert(prefs.enableNotifications == true);
    assert(prefs.useDeviceAuth == true);
    assert(prefs.schemaVersion == 1);
    expect(prefs.createdAt, isNotNull);
    expect(prefs.updatedAt, isNotNull);
  });

  test('setMaskCardNumber updates the value', () {
    PreferencesModel prefs = PreferencesModel();
    prefs.setMaskCardNumber(false);
    assert(prefs.maskCardNumber == false);
  });

  test('setMaskCVV updates the value', () {
    PreferencesModel prefs = PreferencesModel();
    prefs.setMaskCVV(false);
    assert(prefs.maskCVV == false);
  });

  test('setEnableNotifications updates the value', () {
    PreferencesModel prefs = PreferencesModel();
    prefs.setEnableNotifications(false);
    assert(prefs.enableNotifications == false);
  });

  test('setUseDeviceAuth updates the value', () {
    PreferencesModel prefs = PreferencesModel();
    prefs.setUseDeviceAuth(false);
    assert(prefs.useDeviceAuth == false);
  });

  test('multiple preference changes update independently', () {
    PreferencesModel prefs = PreferencesModel();
    prefs.setMaskCardNumber(false);
    assert(prefs.maskCardNumber == false);
    assert(prefs.maskCVV == true);
    
    prefs.setEnableNotifications(false);
    assert(prefs.enableNotifications == false);
    assert(prefs.maskCVV == true);
    assert(prefs.useDeviceAuth == true);
  });

  test('all boolean preferences can be toggled independently', () {
    PreferencesModel prefs = PreferencesModel();
    
    prefs.setMaskCardNumber(false);
    prefs.setMaskCVV(false);
    prefs.setEnableNotifications(false);
    prefs.setUseDeviceAuth(false);
    
    assert(prefs.maskCardNumber == false);
    assert(prefs.maskCVV == false);
    assert(prefs.enableNotifications == false);
    assert(prefs.useDeviceAuth == false);
  });
}
