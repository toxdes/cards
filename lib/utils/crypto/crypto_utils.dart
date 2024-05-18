import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cards/utils/crypto/aes_cbc.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:pointycastle/export.dart';

class CryptoUtilsErrorCodes {
  static const invalidPadLength = 0x100;
  static const notInitialized = 0x101;
}

class CryptoUtilsException implements Exception {
  final String message;
  final int errorCode;
  CryptoUtilsException(this.errorCode, this.message);
  @override
  String toString() {
    return '[CryptoUtilsException] Error $errorCode: $message';
  }
}

class PadTextResult {
  int paddedBytesCount;
  Uint8List data;
  PadTextResult({required this.paddedBytesCount, required this.data});
}

class CryptoUtils {
  static AesCbc? aes;
  static Random? rnd;
  static bool _initialized = false;
  static Future<void> init() async {
    rnd = Random.secure();
    Uint8List salt = StringUtils.toBytes("todo-figure-out-salt");
    Uint8List iv = Uint8List(AesCbc.blockSizeInBytes);
    for (int i = 0; i < iv.length; ++i) {
      iv[i] = rnd!.nextInt(255);
    }
    aes = AesCbc(iv: iv, salt: salt);
    _initialized = true;
  }

  /// extrapolates a key of small length to the desired length using `argon_2_id` algorithm.
  static Uint8List deriveKey(
      int desiredKeyLength, Uint8List key, Uint8List salt) {
    Argon2BytesGenerator generator = Argon2BytesGenerator();
    Argon2Parameters params = Argon2Parameters(Argon2Parameters.ARGON2_id, salt,
        desiredKeyLength: desiredKeyLength);
    generator.init(params);
    Uint8List out = Uint8List(desiredKeyLength);
    generator.deriveKey(key, 0, out, 0);
    return out;
  }

  static AesResult aesEncrypt(Uint8List key, Uint8List text) {
    if (!_initialized) {
      throw CryptoUtilsException(CryptoUtilsErrorCodes.notInitialized,
          "Tried to call aesEncrypt from CryptoUtils without calling init() first.");
    }
    BytesBuilder encryptedText = BytesBuilder();
    Uint8List block = Uint8List(AesCbc.blockSizeInBytes);
    int i = 0;
    int bp = 0;
    while (i < text.length) {
      if (bp == AesCbc.blockSizeInBytes) {
        encryptedText.add(aes!.encryptBlock(key, block));
        bp = 0;
        continue;
      }
      block[bp] = text[i];
      ++bp;
      ++i;
    }
    int paddedBytesCount = 0;
    if (bp > 0) {
      // last block.
      Uint8List lastBlock = Uint8List(bp);
      for (int i = 0; i < bp; ++i) {
        lastBlock[i] = block[i];
      }
      encryptedText.add(aes!.encryptBlock(key, lastBlock));
      paddedBytesCount = aes!.getLastPaddedBytesCount();
    }
    return AesResult(
        data: encryptedText.toBytes(), paddedBytesCount: paddedBytesCount);
  }

  static AesResult aesDecrypt(Uint8List key, Uint8List text) {
    if (!_initialized) {
      throw CryptoUtilsException(CryptoUtilsErrorCodes.notInitialized,
          "Tried to call aesDecrypt from CryptoUtils without calling init() first.");
    }
    BytesBuilder decryptedText = BytesBuilder();
    Uint8List block = Uint8List(AesCbc.blockSizeInBytes);
    int i = 0;
    int bp = 0;
    while (i < text.length) {
      if (bp == block.length) {
        decryptedText.add(aes!.decryptBlock(key, block));
        bp = 0;
        continue;
      }
      block[bp] = text[i];
      ++bp;
      ++i;
    }
    int paddedBytesCount = 0;
    if (bp > 0) {
      // last block.
      Uint8List lastBlock = Uint8List(bp);
      for (int i = 0; i < bp; ++i) {
        lastBlock[i] = block[i];
      }
      decryptedText.add(aes!.decryptBlock(key, lastBlock));
      paddedBytesCount = aes!.getLastPaddedBytesCount();
    }
    return AesResult(
        data: decryptedText.toBytes(), paddedBytesCount: paddedBytesCount);
  }

  static PadTextResult padText(Uint8List text, int length) {
    if (text.length > length) {
      throw CryptoUtilsException(CryptoUtilsErrorCodes.invalidPadLength,
          "Invalid pad length $length for PKCS7 text padding. Pad length should not be smaller than text length.");
    }
    PKCS7Padding padding = PKCS7Padding();
    padding.init();
    Uint8List paddedText = Uint8List(length);
    for (int i = 0; i < text.length; ++i) {
      paddedText[i] = text[i];
    }
    int paddedBytesCount = padding.addPadding(paddedText, text.length);
    return PadTextResult(paddedBytesCount: paddedBytesCount, data: paddedText);
  }
}
