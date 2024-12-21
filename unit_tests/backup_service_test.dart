import 'package:cards/services/backup_service.dart';
import 'package:cards/utils/crypto/crypto_utils.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

void main() {
  test(
      "encrypt,decrypt, generateKey, generateSalt throw if called before calling init",
      () async {
    // generateKey throws
    expect(() async {
      await BackupService.generateKey();
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.calledWithoutInit)));

    // generateSalt throws
    expect(() async {
      await BackupService.generateSalt();
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.calledWithoutInit)));

    // encrypt throws
    expect(() async {
      await BackupService.encrypt(
          key: "hello-world",
          data: StringUtils.toBytes("hello-world"),
          salt: "hello-world");
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.calledWithoutInit)));

    // decrypt throws
    expect(() async {
      await BackupService.decrypt(
          key: "hello-world",
          data: StringUtils.toBytes("hello-world"),
          salt: "hello-world");
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.calledWithoutInit)));
  });

  test("encrypt, decrypt throw for invalid key", () async {
    await CryptoUtils.init();
    await BackupService.init();
    String invalidKey = "hello world";
    Uint8List input = StringUtils.toBytes("hello world");
    String salt = await BackupService.generateSalt();
    // key is invalid
    assert(BackupService.isKeyValid(invalidKey) == false);

    // encrypt throws
    expect(() async {
      await BackupService.encrypt(key: invalidKey, data: input, salt: salt);
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.invalidKey)));

    // decrypt throws
    expect(() async {
      await BackupService.decrypt(key: invalidKey, data: input, salt: salt);
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.invalidKey)));
  });

  test("generateKey generates a valid key", () async {
    await CryptoUtils.init();
    await BackupService.init();
    String key = await BackupService.generateKey();
    assert(BackupService.isKeyValid(key));
  });

  test("generateSalt generates a valid salt", () async {
    await CryptoUtils.init();
    await BackupService.init();
    String salt = await BackupService.generateSalt();
    assert(BackupService.isSaltValid(salt));
  });

  test("encrypt-decrypt: escape charaters and emojis", () async {
    await CryptoUtils.init();
    await BackupService.init();
    String key = await BackupService.generateKey();
    String salt = await BackupService.generateSalt();
    String secretInput =
        "hello world foo bar escape characters \\\\\taay\r\n emojis 🤣🤣";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput), salt: salt);
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted, salt: salt);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });

  test("encrypt-decrypt: text smaller than 1 block", () async {
    await CryptoUtils.init();
    await BackupService.init();
    String key = await BackupService.generateKey();
    String salt = await BackupService.generateSalt();
    String secretInput = "hell";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput), salt: salt);
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted, salt: salt);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });

  test("encrypt-decrypt: empty text", () async {
    await CryptoUtils.init();
    await BackupService.init();
    String key = await BackupService.generateKey();
    String salt = await BackupService.generateSalt();
    String secretInput = "";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput), salt: salt);
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted, salt: salt);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });

  test("encrypt-decrypt: accent characters", () async {
    await CryptoUtils.init();
    await BackupService.init();
    String key = await BackupService.generateKey();
    String salt = await BackupService.generateSalt();
    String secretInput =
        "This contains accent characters: \u00eb \u00ef केजरीवाल";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput), salt: salt);
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted, salt: salt);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });

  test("decrypt fails for valid but incorrect key", () async {
    await CryptoUtils.init();
    await BackupService.init();
    String correctKey = await BackupService.generateKey();
    String correctSalt = await BackupService.generateSalt();
    String incorrectKey = await BackupService.generateKey();
    String incorrectSalt = await BackupService.generateSalt();
    Uint8List secretInput = StringUtils.toBytes("hello-world");
    Uint8List encrypted = await BackupService.encrypt(
        key: correctKey, data: secretInput, salt: correctSalt);

    // decrypts for correctKey - correctSalt
    await BackupService.decrypt(
        data: encrypted, key: correctKey, salt: correctSalt);

    // throws for incorrectKey - correctSalt
    expect(() async {
      await BackupService.decrypt(
          key: incorrectKey, data: encrypted, salt: correctSalt);
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.incorrectCreds)));

    // throws for correctKey - incorrectSalt
    expect(() async {
      await BackupService.decrypt(
          key: correctKey, data: encrypted, salt: incorrectSalt);
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.incorrectCreds)));

    // throws for incorrectKey - incorrectSalt
    expect(() async {
      await BackupService.decrypt(
          key: incorrectKey, data: encrypted, salt: incorrectSalt);
    },
        throwsA(predicate((e) =>
            e is BackupServiceException &&
            e.errorCode == BackupServiceErrorCodes.incorrectCreds)));
  });

  test('actual data', () async {
    await CryptoUtils.init();
    await BackupService.init();
    String key = await BackupService.generateKey();
    String salt = await BackupService.generateSalt();

    String secretInput = """ [{
        "schemaVersion":"2",
        "title": "asd",
        "number": "2412123223123342",
        "provider": "Unknown",
        "cvv": "203",
        "type": "Unknown",
        "expiry": "0892",
        "ownerName": "VA",
        "createdAt": "1734754654021640",
        "updatedAt": "1734754654021649",
        "billingCycle": "15"
}
     ,{
   "schemaVersion":"2",
   "title": "Apay",
   "number": "4123324343434334",
   "provider": "VISA",
   "cvv": "509",
   "type": "Unknown",
   "expiry": "1124",
   "ownerName": "VAIBHAV",
   "createdAt": "1734750063860397",
   "updatedAt": "1734750063860512",
   "billingCycle": "15"
 }
  ]
""";
    Uint8List secretInputBytes = StringUtils.toBytes(secretInput);
    Uint8List encrypted = await BackupService.encrypt(
        key: key, data: StringUtils.toBytes(secretInput), salt: salt);
    Uint8List decrypted =
        await BackupService.decrypt(key: key, data: encrypted, salt: salt);
    assert(secretInputBytes.length == decrypted.length);
    for (int i = 0; i < secretInputBytes.length; ++i) {
      assert(secretInputBytes[i] == decrypted[i]);
    }
    String output = StringUtils.fromBytes(decrypted);
    assert(output == secretInput);
  });
}
