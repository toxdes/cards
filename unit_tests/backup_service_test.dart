import 'package:cards/services/backup_service.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

void main() {
  test("generateKey generates a valid key", () async {
    await BackupService.init();
    String key = await BackupService.generateKey();
    assert(key.length == BackupService.keyLength);
    RegExp keyRegex = RegExp(r'^[0-9]{12}$');
    assert(keyRegex.hasMatch(key));
  });

  test("backup service encryption and decryption works", () async {
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
  });
}
