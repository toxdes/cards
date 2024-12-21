import 'dart:math';
import 'dart:typed_data';

import 'package:cards/utils/crypto/aes_cbc.dart';
import 'package:cards/utils/crypto/crypto_utils.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:pointycastle/export.dart';

class BackupServiceErrorCodes {
  static const int invalidKey = 0x100;
  static const int calledWithoutInit = 0x101;
  static const int incorrectCreds = 0x102;
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
  static SecureRandom? _random;
  static const int keyLength = 12;
  static const int saltLength = 8;
  static const _encryptionKeyInBytes = 32;
  static bool _initialized = false;
  static String keySeparator = "-";
  static String allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static Future<void> init() async {
    Random r = Random.secure();
    Uint8List bytes = Uint8List(32);
    for (int i = 0; i < 32; ++i) {
      bytes[i] = r.nextInt(allowedChars.length);
    }
    _random = FortunaRandom()..seed(KeyParameter(bytes));
    _initialized = true;
  }

  static String getKeyShape() {
    return "XXXX-XXXX-XXXX";
  }

  static String getSecretShape() {
    return "XXXX-XXXX";
  }

  static Future<String> generateKey() async {
    // key is a string of length BackupService.keyLength
    if (!_initialized) {
      throw BackupServiceException(BackupServiceErrorCodes.calledWithoutInit,
          "Backup service is not initialized");
    }

    StringBuffer buf = StringBuffer();
    for (int i = 0; i < keyLength; ++i) {
      int num = _random!.nextUint32();
      buf.write(allowedChars[num % allowedChars.length]);
    }
    return buf.toString();
  }

  static bool isKeyValid(String maybeKey) {
    RegExp keyRegex = RegExp("^[A-Z0-9]{$keyLength}\$");
    return maybeKey.length == BackupService.keyLength &&
        keyRegex.hasMatch(maybeKey);
  }

  static bool isSaltValid(String maybeSalt) {
    RegExp saltRegex = RegExp("^[A-Z0-9]{$saltLength}\$");
    return maybeSalt.length == BackupService.saltLength &&
        saltRegex.hasMatch(maybeSalt);
  }

  static Future<String> generateSalt() async {
    if (!_initialized) {
      throw BackupServiceException(BackupServiceErrorCodes.calledWithoutInit,
          "Backup service is not initialized");
    }
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < saltLength; ++i) {
      int num = _random!.nextUint32();
      buf.write(allowedChars[num % allowedChars.length]);
    }
    return buf.toString();
  }

  static Future<Uint8List> encrypt(
      {required String key,
      required Uint8List data,
      required String salt}) async {
    if (!_initialized) {
      throw BackupServiceException(BackupServiceErrorCodes.calledWithoutInit,
          "Backup service is not initialized");
    }
    if (!BackupService.isKeyValid(key)) {
      throw BackupServiceException(
          BackupServiceErrorCodes.invalidKey, "cannot encrypt, key is invalid");
    }

    Uint8List encryptionKey = CryptoUtils.deriveKey(_encryptionKeyInBytes,
        StringUtils.toBytes(key), StringUtils.toBytes(salt));
    AesResult encrypted = CryptoUtils.aesEncrypt(encryptionKey, data);
    return encrypted.data;
  }

  static Future<Uint8List> decrypt(
      {required String key,
      required Uint8List data,
      required String salt}) async {
    if (!_initialized) {
      throw BackupServiceException(BackupServiceErrorCodes.calledWithoutInit,
          "Backup service is not initialized");
    }
    if (!BackupService.isKeyValid(key)) {
      throw BackupServiceException(
          BackupServiceErrorCodes.invalidKey, "cannot decrypt, key is invalid");
    }

    Uint8List decryptionKey = CryptoUtils.deriveKey(_encryptionKeyInBytes,
        StringUtils.toBytes(key), StringUtils.toBytes(salt));
    try {
      AesResult decrypted = CryptoUtils.aesDecrypt(decryptionKey, data);
      return decrypted.data;
    } catch (e) {
      if (e is CryptoUtilsException &&
          e.errorCode == CryptoUtilsErrorCodes.invalidCredentials) {
        throw BackupServiceException(BackupServiceErrorCodes.incorrectCreds,
            "cannot decrypt, credentials are incorrect");
      }
      rethrow;
    }
  }
}
