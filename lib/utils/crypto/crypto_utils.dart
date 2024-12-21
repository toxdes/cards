import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cards/utils/crypto/aes_cbc.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:pointycastle/export.dart';

class CryptoUtilsErrorCodes {
  static const invalidPadLength = 0x100;
  static const notInitialized = 0x101;
  static const invalidCredentials = 0x103;
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
  static Random? rnd;
  static bool _initialized = false;
  // TODO: explore CMAC instead of this
  static const String _magic = "enc453Xyz4512a4W";
  static int _headerLength = _magic.length;

  static Future<void> init() async {
    rnd = Random.secure();
    _initialized = true;
    _headerLength = StringUtils.toBytes(_magic).length;
  }

  static Uint8List getIV(Uint8List key) {
    Uint8List iv = Uint8List(AesCbc.blockSizeInBytes);
    for (int i = 0; i < iv.length; ++i) {
      iv[i] = key[i % key.length];
    }
    return iv;
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
    BytesBuilder builder = BytesBuilder();
    builder.add(StringUtils.toBytes(CryptoUtils._magic));
    builder.add(text);
    Uint8List textWithHeader = builder.toBytes();
    BytesBuilder encryptedText = BytesBuilder();
    Uint8List block = Uint8List(AesCbc.blockSizeInBytes);
    int i = 0;
    int bp = 0;
    AesCbc aes = AesCbc();
    aes.setIV(CryptoUtils.getIV(key));
    while (i < textWithHeader.length) {
      if (bp == AesCbc.blockSizeInBytes) {
        encryptedText.add(aes.encryptBlock(key, block, false));
        bp = 0;
        continue;
      }
      block[bp] = textWithHeader[i];
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
      encryptedText.add(aes.encryptBlock(key, lastBlock, true));
      paddedBytesCount = aes.getLastPaddedBytesCount();
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
    AesCbc aes = AesCbc();
    aes.setIV(CryptoUtils.getIV(key));
    while (i < text.length) {
      if (bp == AesCbc.blockSizeInBytes) {
        decryptedText.add(aes.decryptBlock(key, block, false).toList());
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
      decryptedText.add(aes.decryptBlock(key, lastBlock, true));
      paddedBytesCount = aes.getLastPaddedBytesCount();
    }
    Uint8List decrypted = decryptedText.toBytes();
    Uint8List header = StringUtils.toBytes(CryptoUtils._magic);
    if (decrypted.length < CryptoUtils._headerLength) {
      throw CryptoUtilsException(CryptoUtilsErrorCodes.invalidCredentials,
          "cannot decrypt, invalid credentials");
    }
    for (int i = 0; i < CryptoUtils._headerLength; ++i) {
      if (header[i] != decrypted[i]) {
        throw CryptoUtilsException(CryptoUtilsErrorCodes.invalidCredentials,
            "cannot decrypt, invalid credentials");
      }
    }
    Uint8List decryptedWithoutHeader =
        Uint8List(decryptedText.length - CryptoUtils._headerLength);
    for (int i = 0; i < decrypted.length; ++i) {
      if (i < CryptoUtils._headerLength) continue;
      decryptedWithoutHeader[i - CryptoUtils._headerLength] = decrypted[i];
    }
    return AesResult(
        data: decryptedWithoutHeader, paddedBytesCount: paddedBytesCount);
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
