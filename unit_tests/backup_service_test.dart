import 'package:cards/services/backup_service.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

void main() {
  test("encrypt, decrypt and generateSalt throw for invalid key", () async {
    await BackupService.init();
    String invalidKey = "hello world";
    Uint8List input = StringUtils.toBytes("hello world");
    // key is invalid
    assert(BackupService.isKeyValid(invalidKey) == false);

    // generateSalt throws
    expect(() async {
      await BackupService.generateSalt(invalidKey);
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.invalidKey)));

    // encrypt throws
    expect(() async {
      await BackupService.encrypt(key: invalidKey, data: input);
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.invalidKey)));

    // decrypt throws
    expect(() async {
      await BackupService.decrypt(key: invalidKey, data: input);
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.invalidKey)));
  });
  test("generateKey generates a valid key", () async {
    await BackupService.init();
    String key = await BackupService.generateKey();
    assert(BackupService.isKeyValid(key));
  });

  test("encrypt-decrypt: escape charaters and emojis", () async {
    await BackupService.init();
    String key = await BackupService.generateKey();
    String secretInput =
        "hello world foo bar escape characters \\\\\taay\r\n emojis 🤣🤣";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput));
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });

  test("encrypt-decrypt: text smaller than 1 block", () async {
    await BackupService.init();
    String key = await BackupService.generateKey();
    String secretInput = "hell";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput));
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });

  test("encrypt-decrypt: empty text", () async {
    await BackupService.init();
    String key = await BackupService.generateKey();
    String secretInput = "";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput));
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });

  test("encrypt-decrypt: accent characters", () async {
    await BackupService.init();
    String key = await BackupService.generateKey();
    String secretInput =
        "This contains accent characters: \u00eb \u00ef केजरीवाल";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput));
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });
}
