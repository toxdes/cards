import 'package:cards/services/backup_service.dart';
import 'package:flutter/services.dart';

class SecretFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String existingText = newValue.text;
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < existingText.length; ++i) {
      if (BackupService.allowedChars.contains(existingText[i].toUpperCase()) ||
          existingText[i] == BackupService.keySeparator) {
        buf.write(existingText[i].toUpperCase());
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class KeyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String existingText = newValue.text;
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < existingText.length; ++i) {
      if (BackupService.allowedChars.contains(existingText[i].toUpperCase()) ||
          existingText[i] == BackupService.keySeparator) {
        buf.write(existingText[i].toUpperCase());
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class RestoreFieldsFormatter {
  static secretFormatter() {
    return SecretFormatter();
  }

  static keyFormatter() {
    return KeyFormatter();
  }
}
