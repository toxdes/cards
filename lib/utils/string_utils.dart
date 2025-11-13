import 'dart:convert';
import 'package:flutter/foundation.dart';

class StringUtils {
  static bool isWhitespace(String s) {
    return s == ' ' || s == '\t' || s == '\n';
  }

  static bool isDigit(String s) {
    int? res = int.tryParse(s);
    return s.length == 1 && res != null && res >= 0 && res <= 9;
  }

  static bool isAlphabetOrSpace(String s) {
    RegExp alphabetRegex = RegExp(r'^[a-zA-Z\ ]$');
    return alphabetRegex.hasMatch(s);
  }

  static bool isOnlyDigits(String input, {bool ignoreWhitespace = true}) {
    bool hasOnlyDigits = true;
    for (int i = 0; i < input.length; ++i) {
      if (ignoreWhitespace && isWhitespace(input[i])) continue;
      if (!isDigit(input[i])) {
        hasOnlyDigits = false;
        break;
      }
    }
    return hasOnlyDigits;
  }

  static String removeAll(String input, String pat) {
    return input.replaceAll(pat, '');
  }

  static Uint8List toBytes(String input) {
    return Uint8List.fromList(utf8.encode(input));
  }

  static String fromBytes(Uint8List bytes) {
    return utf8.decode(bytes, allowMalformed: true);
  }

  static String printableBytes(Uint8List list) {
    StringBuffer buf = StringBuffer();
    buf.write("Bytes: ");
    buf.write("${list.toList()}");
    return buf.toString();
  }

  static String formatKey(String key, String separator) {
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < key.length; ++i) {
      if (i != 0 && i != key.length && i % 4 == 0) {
        buf.write(separator);
      }
      buf.write(key[i]);
    }
    return buf.toString();
  }
}
