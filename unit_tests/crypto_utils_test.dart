import 'dart:typed_data';

import 'package:cards/utils/aes_cbc.dart';
import 'package:cards/utils/crypto_utils.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  test('derive key derives a key from input', () {
    String key = "123456789012";
    String salt = "salt";
    Uint8List expandedKey = CryptoUtils.deriveKey(
        16, StringUtils.toBytes(key), StringUtils.toBytes(salt));
    assert(expandedKey.length == 16);
  });

  // TODO: add more tests
  test("aes-cbc encryption works correctly", () async {
    await CryptoUtils.init();
    String key = "mykey";
    String salt = "salt";
    String input =
        "some really really long text with newlines and emojis\r\t\t\nwow 🤣";
    Uint8List expandedKey = CryptoUtils.deriveKey(
        32, StringUtils.toBytes(key), StringUtils.toBytes(salt));
    AesResult encrypted =
        CryptoUtils.aesEncrypt(expandedKey, StringUtils.toBytes(input));

    AesResult decrypted = CryptoUtils.aesDecrypt(expandedKey, encrypted.data);

    Uint8List inputBytes = StringUtils.toBytes(input);

    assert(decrypted.paddedBytesCount == 0);
    assert(inputBytes.length == decrypted.data.length);
    String result = StringUtils.fromBytes(decrypted.data);
    assert(input == result);
  });
}
