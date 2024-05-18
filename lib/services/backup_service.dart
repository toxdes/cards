import 'dart:math';
import 'dart:typed_data';

import 'package:cards/utils/crypto/aes_cbc.dart';
import 'package:cards/utils/crypto/crypto_utils.dart';
import 'package:cards/utils/string_utils.dart';

class BackupServiceErrorCodes {
  static const int invalidKey = 0x100;
}

class BackupServiceException implements Exception {
  final String message;
  final int errorCode;
  BackupServiceException(this.errorCode, this.message);
  @override
  String toString() {
    return '[BackupServiceException] Error $errorCode: $message';
  }
}

class BackupService {
  static Random _random = Random();
  static const int keyLength = 12;
  static const _encryptionKeyInBytes = 32;
  static bool _initialized = false;

  static Future<void> init() async {
    _random = Random.secure();
    await CryptoUtils.init();
    _initialized = true;
  }

  static Future<String> generateKey() async {
    // key is a 12 digit number
    if (!_initialized) {
      throw Exception("Backup service is not initialized");
    }
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < keyLength; ++i) {
      int num = _random.nextInt(10);
      buf.write(num.toString());
    }
    return buf.toString();
  }

  static bool isKeyValid(String key) {
    RegExp keyRegex = RegExp(r'^[0-9]{12}');
    return key.length == BackupService.keyLength && keyRegex.hasMatch(key);
  }

  static Future<String> generateSalt(String key) async {
    if (!BackupService.isKeyValid(key)) {
      throw BackupServiceException(BackupServiceErrorCodes.invalidKey,
          "cannot generate salt, key is invalid.");
    }

    // NOTE: currently we don't have a good way to associate a key with a salt that would not require the user to remember more information than the key. figure a way to fix this.
    return '${key[1]}${key[2]}${key[3]}${key[5]}${key[7]}';
  }

  static Future<Uint8List> encrypt(
      {required String key, required Uint8List data}) async {
    if (!BackupService.isKeyValid(key)) {
      throw BackupServiceException(
          BackupServiceErrorCodes.invalidKey, "cannot encrypt, key is invalid");
    }

    Uint8List salt = StringUtils.toBytes(await BackupService.generateSalt(key));
    Uint8List encryptionKey = CryptoUtils.deriveKey(
        _encryptionKeyInBytes, StringUtils.toBytes(key), salt);
    AesResult encrypted = CryptoUtils.aesEncrypt(encryptionKey, data);
    return encrypted.data;
  }

  static Future<Uint8List> decrypt(
      {required String key, required Uint8List data}) async {
    if (!BackupService.isKeyValid(key)) {
      throw BackupServiceException(
          BackupServiceErrorCodes.invalidKey, "cannot decrypt, key is invalid");
    }

    Uint8List salt = StringUtils.toBytes(await BackupService.generateSalt(key));
    Uint8List decryptionKey = CryptoUtils.deriveKey(
        _encryptionKeyInBytes, StringUtils.toBytes(key), salt);
    AesResult decrypted = CryptoUtils.aesDecrypt(decryptionKey, data);
    return decrypted.data;
  }
}
