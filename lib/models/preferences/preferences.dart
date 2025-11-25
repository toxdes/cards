import 'package:cards/core/db/model.dart';

class PreferencesModel extends Model {
  PreferencesModel() : super(schemaVersion: 1) {
    _initDefaults();
  }

  PreferencesModel.fromSchema(int schemaVersion)
      : super(schemaVersion: schemaVersion) {
    _initDefaults();
  }

  bool _maskCardNumber = false;
  bool _maskCVV = false;
  bool _enableNotifications = false;
  bool _useDeviceAuth = false;
  DateTime _createdAt = DateTime.now();
  DateTime _updatedAt = DateTime.now();

  void _initDefaults() {
    _maskCardNumber = true;
    _maskCVV = true;
    _enableNotifications = true;
    _useDeviceAuth = true;
    _createdAt = DateTime.now();
    _updatedAt = DateTime.now();
  }

  void _updateTs() {
    _updatedAt = DateTime.now();
  }

  void setMaskCardNumber(bool maskCardNumber) {
    _maskCardNumber = maskCardNumber;
    _updateTs();
  }

  void setMaskCVV(bool maskCVV) {
    _maskCVV = maskCVV;
    _updateTs();
  }

  void setEnableNotifications(bool enableNotifs) {
    _enableNotifications = enableNotifs;
    _updateTs();
  }

  void setUseDeviceAuth(bool useDeviceAuth) {
    _useDeviceAuth = useDeviceAuth;
    _updateTs();
  }

  void setCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
  }

  void setUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
  }

  bool get maskCardNumber => _maskCardNumber;
  bool get maskCVV => _maskCVV;
  bool get enableNotifications => _enableNotifications;
  bool get useDeviceAuth => _useDeviceAuth;

  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;
}
