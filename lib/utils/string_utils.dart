class StringUtils {
  static bool isWhitespace(String s) {
    return s == ' ' || s == '\t' || s == '\n';
  }

  static bool isDigit(String s) {
    int? res = int.tryParse(s);
    return s.length == 1 && res != null && res >= 0 && res <= 9;
  }

  static isAlphabetOrSpace(String s) {
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
}
