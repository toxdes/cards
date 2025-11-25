import 'package:cards/models/preferences/preferences.dart';
import 'package:cards/models/preferences/preferences_factory.dart';
import 'package:cards/models/preferences/preferences_json_encoder.dart';
import 'package:test/test.dart';

void main() {
  test('encoder-decoder works correctly for default preferences', () {
    PreferencesModel prefs = PreferencesFactory.defaultPrefs();
    PreferencesEncoder encoder = PreferencesEncoder();
    // encode
    String encodedPrefs = encoder.encode(prefs);
    // decode
    PreferencesModel decodedPrefs = encoder.decode(encodedPrefs);
    // compare
    assert(decodedPrefs.maskCardNumber == prefs.maskCardNumber);
    assert(decodedPrefs.maskCVV == prefs.maskCVV);
    assert(decodedPrefs.enableNotifications == prefs.enableNotifications);
    assert(decodedPrefs.useDeviceAuth == prefs.useDeviceAuth);
    assert(decodedPrefs.schemaVersion == prefs.schemaVersion);
  });

  test('encoder-decoder preserves custom preferences', () {
    PreferencesModel prefs = PreferencesModel();
    prefs.setMaskCardNumber(false);
    prefs.setEnableNotifications(false);
    
    PreferencesEncoder encoder = PreferencesEncoder();
    // encode
    String encodedPrefs = encoder.encode(prefs);
    // decode
    PreferencesModel decodedPrefs = encoder.decode(encodedPrefs);
    
    // compare
    assert(decodedPrefs.maskCardNumber == false);
    assert(decodedPrefs.maskCVV == true);
    assert(decodedPrefs.enableNotifications == false);
    assert(decodedPrefs.useDeviceAuth == true);
  });

  test('encoder-decoder preserves timestamps', () {
    PreferencesModel prefs = PreferencesModel();
    DateTime createdAt = DateTime(2020, 1, 1).toUtc();
    DateTime updatedAt = DateTime(2020, 1, 2).toUtc();
    
    prefs.setCreatedAt(createdAt);
    prefs.setUpdatedAt(updatedAt);
    
    PreferencesEncoder encoder = PreferencesEncoder();
    String encodedPrefs = encoder.encode(prefs);
    PreferencesModel decodedPrefs = encoder.decode(encodedPrefs);
    
    assert(
      decodedPrefs.createdAt.toUtc().microsecondsSinceEpoch ==
          createdAt.toUtc().microsecondsSinceEpoch,
    );
    assert(
      decodedPrefs.updatedAt.toUtc().microsecondsSinceEpoch ==
          updatedAt.toUtc().microsecondsSinceEpoch,
    );
  });

  test('decoder handles incomplete JSON gracefully for backward compatibility',
      () {
    String prefsJson = '{"schemaVersion": 1}';
    PreferencesEncoder encoder = PreferencesEncoder();
    // Should not throw - handles incomplete data gracefully with defaults
    PreferencesModel decodedPrefs = encoder.decode(prefsJson);
    assert(decodedPrefs.maskCardNumber == true);
    assert(decodedPrefs.maskCVV == true);
    assert(decodedPrefs.enableNotifications == true);
    assert(decodedPrefs.useDeviceAuth == true);
  });

  test('decoder handles old format with string schemaVersion', () {
    String oldFormatJson = '{'
        '"schemaVersion":"1",'
        '"maskCardNumber":true,'
        '"maskCVV":false,'
        '"enableNotifications":true,'
        '"useDeviceAuth":false'
        '}';
    PreferencesEncoder encoder = PreferencesEncoder();
    
    PreferencesModel decodedPrefs = encoder.decode(oldFormatJson);
    assert(decodedPrefs.schemaVersion == 1);
    assert(decodedPrefs.maskCardNumber == true);
    assert(decodedPrefs.maskCVV == false);
    assert(decodedPrefs.enableNotifications == true);
    assert(decodedPrefs.useDeviceAuth == false);
  });

  test('decoder handles old format with string timestamps', () {
    String oldFormatJson = '{'
        '"schemaVersion":1,'
        '"maskCardNumber":true,'
        '"maskCVV":true,'
        '"enableNotifications":true,'
        '"useDeviceAuth":true,'
        '"createdAt":"1577836800000000",'
        '"updatedAt":"1577923200000000"'
        '}';
    PreferencesEncoder encoder = PreferencesEncoder();
    
    PreferencesModel decodedPrefs = encoder.decode(oldFormatJson);
    assert(decodedPrefs.createdAt != null);
    assert(decodedPrefs.updatedAt != null);
    assert(
      decodedPrefs.createdAt.toUtc().microsecondsSinceEpoch == 1577836800000000,
    );
  });

  test('decoder handles empty JSON with defaults', () {
    String emptyJson = '{}';
    PreferencesEncoder encoder = PreferencesEncoder();
    
    PreferencesModel decodedPrefs = encoder.decode(emptyJson);
    assert(decodedPrefs.schemaVersion == 0);
    assert(decodedPrefs.maskCardNumber == true);
    assert(decodedPrefs.maskCVV == true);
    assert(decodedPrefs.enableNotifications == true);
    assert(decodedPrefs.useDeviceAuth == true);
  });
}
