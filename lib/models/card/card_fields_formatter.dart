import 'dart:math';

import 'package:cards/utils/string_utils.dart';
import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String textWithoutWhitespace =
        StringUtils.removeAll(newValue.text.toString(), ' ');

    StringBuffer buf = StringBuffer();
    for (int i = 1; i <= min<int>(textWithoutWhitespace.length, 16); ++i) {
      if (StringUtils.isDigit(textWithoutWhitespace[i - 1])) {
        buf.write(textWithoutWhitespace[i - 1]);
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String textWithoutWhitespace =
        StringUtils.removeAll(newValue.text.toString(), ' ');
    String textWithoutSlash = StringUtils.removeAll(textWithoutWhitespace, '/');
    StringBuffer buf = StringBuffer();
    for (int i = 1; i <= min<int>(textWithoutSlash.length, 4); ++i) {
      if (StringUtils.isDigit(textWithoutSlash[i - 1])) {
        buf.write(textWithoutSlash[i - 1]);
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class CvvFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String textWithoutWhitespace =
        StringUtils.removeAll(newValue.text.toString(), ' ');
    StringBuffer buf = StringBuffer();
    for (int i = 1; i <= min<int>(textWithoutWhitespace.length, 3); ++i) {
      if (StringUtils.isDigit(textWithoutWhitespace[i - 1])) {
        buf.write(textWithoutWhitespace[i - 1]);
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class OwnerNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    StringBuffer buf = StringBuffer();
    String newText = newValue.text;
    for (int i = 0; i < newText.length; ++i) {
      if (StringUtils.isAlphabetOrSpace(newText[i])) {
        buf.write(newText[i].toUpperCase());
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class CardFieldsFormatter {
  static CardNumberFormatter numberFormatter() {
    return CardNumberFormatter();
  }

  static ExpiryFormatter expiryFormatter() {
    return ExpiryFormatter();
  }

  static CvvFormatter cvvFormatter() {
    return CvvFormatter();
  }

  static OwnerNameFormatter ownerNameFormatter() {
    return OwnerNameFormatter();
  }
}
