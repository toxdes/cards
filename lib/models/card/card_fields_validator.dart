import 'package:cards/utils/string_utils.dart';

class CardFieldsValidator {
  static String? title(String? maybeTitle) {
    if (maybeTitle == null || maybeTitle.isEmpty) {
      return "title shouldn't be empty";
    }
    return null;
  }

  static String? number(String? maybeNumber) {
    if (maybeNumber == null || maybeNumber.isEmpty) {
      return "number shouldn't be empty";
    }
    if (!StringUtils.isOnlyDigits(maybeNumber)) {
      return "number should only contain digits";
    }
    if (StringUtils.removeAll(maybeNumber, ' ').length != 16) {
      return "number should be exactly 16 digits";
    }
    return null;
  }

  static String? expiry(String? maybeExpiry) {
    if (maybeExpiry == null || maybeExpiry.isEmpty) {
      return "shouldn't be empty";
    }
    String processedExpiry =
        StringUtils.removeAll(StringUtils.removeAll(maybeExpiry, ' '), '/');
    if (processedExpiry.length != 4) {
      return "should match MM/YY";
    }
    int? month = int.tryParse("${processedExpiry[0]}${processedExpiry[1]}");
    if (month == null || month < 1 || month > 12) {
      return "invalid month(MM)";
    }
    int? year = int.tryParse("${processedExpiry[2]}${processedExpiry[3]}");
    if (year == null) {
      return "invalid year(YY)";
    }
    return null;
  }

  static String? cvv(String? maybeCvv) {
    if (maybeCvv == null || maybeCvv.isEmpty) {
      return "shouldn't be empty";
    }
    String processedCvv = StringUtils.removeAll(maybeCvv, ' ');
    if (processedCvv.length != 3) {
      return "should be 3 digits";
    }
    for (int i = 0; i < processedCvv.length; ++i) {
      if (!StringUtils.isDigit(processedCvv[i])) {
        return "only digits allowed";
      }
    }
    return null;
  }

  static String? ownerName(String? maybeOwnerName) {
    if (maybeOwnerName == null || maybeOwnerName.isEmpty) {
      return "name shouldn't be empty.";
    }
    RegExp nameRegex = RegExp(r'^[a-zA-Z\ ]+$');
    if (!nameRegex.hasMatch(maybeOwnerName)) {
      return "name shouldn't have special characters.";
    }
    return null;
  }
}
