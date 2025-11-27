import 'dart:convert';

import 'package:cards/core/encoder/encoder.dart';
import 'package:cards/models/preferences/preferences.dart';
import 'package:cards/models/preferences/preferences_factory.dart';

class PreferencesEncoder implements Encoder<PreferencesModel, String> {
  @override
  PreferencesModel decode(String encodedInput) {
    Map<String, dynamic> record =
        jsonDecode(encodedInput) as Map<String, dynamic>;
    int? schemaVersion;
    final schemaVersionValue = record['schemaVersion'];
    if (schemaVersionValue is int) {
      schemaVersion = schemaVersionValue;
    } else if (schemaVersionValue is String) {
      schemaVersion = int.tryParse(schemaVersionValue);
    }
    schemaVersion ??= 0;

    int? createdAt;
    final createdAtValue = record['createdAt'];
    if (createdAtValue is int) {
      createdAt = createdAtValue;
    } else if (createdAtValue is String) {
      createdAt = int.tryParse(createdAtValue);
    }

    int? updatedAt;
    final updatedAtValue = record['updatedAt'];
    if (updatedAtValue is int) {
      updatedAt = updatedAtValue;
    } else if (updatedAtValue is String) {
      updatedAt = int.tryParse(updatedAtValue);
    }

    PreferencesModel defaultPrefs = PreferencesFactory.defaultPrefs();

    PreferencesModel prefs = PreferencesFactory.fromSchema(schemaVersion);
    prefs
      ..setMaskCVV(record['maskCVV'] ?? defaultPrefs.maskCVV)
      ..setMaskCardNumber(
          record['maskCardNumber'] ?? defaultPrefs.maskCardNumber)
      ..setEnableNotifications(
          record['enableNotifications'] ?? defaultPrefs.enableNotifications)
      ..setUseDeviceAuth(record['useDeviceAuth'] ?? defaultPrefs.useDeviceAuth);

    if (createdAt != null) {
      prefs.setCreatedAt(
          DateTime.fromMicrosecondsSinceEpoch(createdAt, isUtc: true));
    }
    if (updatedAt != null) {
      prefs.setUpdatedAt(
          DateTime.fromMicrosecondsSinceEpoch(updatedAt, isUtc: true));
    }
    return prefs;
  }

  @override
  String encode(PreferencesModel p) {
    final json = <String, dynamic>{
      'schemaVersion': p.schemaVersion,
      'maskCardNumber': p.maskCardNumber,
      'maskCVV': p.maskCVV,
      'enableNotifications': p.enableNotifications,
      'useDeviceAuth': p.useDeviceAuth,
      'createdAt': p.createdAt.toUtc().microsecondsSinceEpoch,
      'updatedAt': p.updatedAt.toUtc().microsecondsSinceEpoch,
    };
    return jsonEncode(json);
  }
}
