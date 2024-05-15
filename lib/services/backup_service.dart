import 'dart:math';
import 'dart:typed_data';

import 'package:cards/utils/aes_cbc.dart';
import 'package:cards/utils/crypto_utils.dart';
import 'package:cards/utils/string_utils.dart';

class BackupService {
  static Random _random = Random();
  static const int keyLength = 12;
  static const _encryptionKeyInBytes = 32;
  static Uint8List salt = Uint8List(0);
  static bool _initialized = false;

  static Future<void> init() async {
    _random = Random.secure();
    await CryptoUtils.init();
    salt = StringUtils.toBytes("todo-salt");
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

  static Future<Uint8List> encrypt(
      {required String key, required Uint8List data}) async {
    Uint8List encryptionKey = CryptoUtils.deriveKey(
        _encryptionKeyInBytes, StringUtils.toBytes(key), salt);
    AesResult encrypted = CryptoUtils.aesEncrypt(encryptionKey, data);
    return encrypted.data;
  }

  static Future<Uint8List> decrypt(
      {required String key, required Uint8List data}) async {
    Uint8List decryptionKey = CryptoUtils.deriveKey(
        _encryptionKeyInBytes, StringUtils.toBytes(key), salt);
    AesResult decrypted = CryptoUtils.aesDecrypt(decryptionKey, data);
    return decrypted.data;
  }
}
