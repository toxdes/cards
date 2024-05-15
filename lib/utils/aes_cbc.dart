import 'dart:typed_data';

import 'package:cards/utils/crypto_utils.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:pointycastle/export.dart';

class AesCbcErrorCodes {
  static const int aesInvalidKeyLength = 0x100;
  static const int aesInvalidIVLength = 0x101;
  static const int aesIncorrectlyPaddedText = 0x102;
  static const int aesInvalidTextLength = 0x103;
}

class AesCbcException implements Exception {
  final String message;
  final int errorCode;
  AesCbcException(this.errorCode, this.message);
  @override
  String toString() {
    return '[AES-CBC Exception] Error $errorCode: $message';
  }
}

class AesResult {
  final int paddedBytesCount;
  final Uint8List data;
  AesResult({required this.paddedBytesCount, required this.data});
  @override
  String toString() {
    return 'AES Result<padded_bytes=$paddedBytesCount data=${StringUtils.printableBytes(data)}>';
  }
}

class AesCbc {
  static List<int> acceptedKeyLengths = [128, 192, 256];
  static const int blockSize = 128;
  static const int blockSizeInBytes = blockSize ~/ 8;
  final Uint8List iv;
  final Uint8List salt;
  int _paddedBytesCount = 0;
  AesCbc({required this.iv, required this.salt});

  /// encrypt a block of size 128 bits
  Uint8List encryptBlock(Uint8List key, Uint8List text) {
    if (!acceptedKeyLengths.contains(key.length * 8)) {
      throw AesCbcException(AesCbcErrorCodes.aesInvalidKeyLength,
          "Invalid key length ${key.length} for AES-CBC encryption. Accepted lengths are ${acceptedKeyLengths[0]}, ${acceptedKeyLengths[1]}, ${acceptedKeyLengths[2]} bits.");
    }
    if (iv.length * 8 != blockSize) {
      throw AesCbcException(AesCbcErrorCodes.aesInvalidIVLength,
          "Invalid parameter IV length ${iv.length} for AES-CBC encryption. Accepted length is $blockSize.");
    }
    if (text.length * 8 > blockSize) {
      throw AesCbcException(AesCbcErrorCodes.aesInvalidTextLength,
          "Invalid text length ${text.length} for AES-CBC encryption. Accepted length is $blockSize.");
    }

    PadTextResult paddedText = CryptoUtils.padText(text, blockSizeInBytes);
    _paddedBytesCount = paddedText.paddedBytesCount;
    if (paddedText.data.length != blockSizeInBytes) {
      throw AesCbcException(AesCbcErrorCodes.aesIncorrectlyPaddedText,
          "Incorrectly padded text length ${paddedText.data.length} for AES-CBC encryption. Accepted length is $blockSize.");
    }

    final CBCBlockCipher cbc = CBCBlockCipher(AESEngine());
    final ParametersWithIV params = ParametersWithIV(KeyParameter(key), iv);
    cbc.init(true, params); // true -> encrypt

    return cbc.process(paddedText.data);
  }

  /// decrypt a block of size 128 bits
  Uint8List decryptBlock(Uint8List key, Uint8List text) {
    if (!acceptedKeyLengths.contains(key.length * 8)) {
      throw AesCbcException(AesCbcErrorCodes.aesInvalidKeyLength,
          "Invalid key length ${key.length} for AES-CBC encryption. Accepted lengths are ${acceptedKeyLengths[0]}, ${acceptedKeyLengths[1]}, ${acceptedKeyLengths[2]} bits.");
    }
    if (iv.length * 8 != blockSize) {
      throw AesCbcException(AesCbcErrorCodes.aesInvalidIVLength,
          "Invalid parameter IV length ${iv.length} for AES-CBC encryption. Accepted length is $blockSize.");
    }
    PadTextResult paddedText = CryptoUtils.padText(text, blockSizeInBytes);
    _paddedBytesCount = paddedText.paddedBytesCount;
    if (paddedText.data.length != blockSizeInBytes) {
      throw AesCbcException(AesCbcErrorCodes.aesIncorrectlyPaddedText,
          "Incorrectly padded text length ${paddedText.data.length} for AES-CBC encryption. Accepted length is $blockSize.");
    }
    final CBCBlockCipher cbc = CBCBlockCipher(AESEngine());
    final ParametersWithIV params = ParametersWithIV(KeyParameter(key), iv);
    cbc.init(false, params); // false -> decrypt
    Uint8List result = cbc.process(paddedText.data);
    // remove padding if exists
    int padLength = result.length - result[result.length - 1];
    if (padLength <= 0) return result;
    BytesBuilder res = BytesBuilder();
    for (int i = 0; i < padLength; ++i) {
      res.addByte(result[i]);
    }
    return res.toBytes();
  }

  int getLastPaddedBytesCount() {
    return _paddedBytesCount;
  }
}
