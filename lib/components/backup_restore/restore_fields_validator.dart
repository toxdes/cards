import 'package:cards/services/backup_service.dart';

class RestoreFieldsValidator {
  static String? secret(String? maybeSecret) {
    if (maybeSecret == null || maybeSecret.isEmpty) {
      return "secret shouldn't be empty";
    }
    List<int> separatorPos = [];
    for (int i = 0; i < maybeSecret.length; ++i) {
      if (maybeSecret[i] == BackupService.keySeparator) {
        separatorPos.add(i);
      }
    }
    int lengthWithoutSeparator = maybeSecret.length - separatorPos.length;
    if (separatorPos.isNotEmpty) {
      for (int i = 0; i < separatorPos.length; ++i) {
        if (separatorPos[i] % 5 != 4 ||
            separatorPos[i] == maybeSecret.length - 1 ||
            lengthWithoutSeparator != BackupService.saltLength) {
          return "secret isn't of the form ${BackupService.getSecretShape()}";
        }
      }
    }
    if (lengthWithoutSeparator != BackupService.saltLength) {
      return "secret must be ${BackupService.saltLength} characters long";
    }
    return null;
  }

  static String? key(String? maybeKey) {
    if (maybeKey == null || maybeKey.isEmpty) {
      return "key shouldn't be empty";
    }

    List<int> separatorPos = [];

    for (int i = 0; i < maybeKey.length; ++i) {
      if (maybeKey[i] == BackupService.keySeparator) {
        separatorPos.add(i);
      }
    }

    int lengthWithoutSeparator = maybeKey.length - separatorPos.length;

    if (separatorPos.isNotEmpty) {
      for (int i = 0; i < separatorPos.length; ++i) {
        bool isKeyInvalid = false;

        // key has '-' is at correct positions
        isKeyInvalid |= separatorPos[i] % 5 != 4;
        // key doesn't end with '-'
        isKeyInvalid |= separatorPos[i] == maybeKey.length - 1;
        // key has valid length ignoring '-'
        isKeyInvalid |= lengthWithoutSeparator != BackupService.keyLength;

        if (isKeyInvalid) {
          return "key isn't of the form ${BackupService.getKeyShape()}";
        }
      }
    }

    if (lengthWithoutSeparator != BackupService.keyLength) {
      return "key must be ${BackupService.keyLength} characters long.";
    }

    return null;
  }
}
