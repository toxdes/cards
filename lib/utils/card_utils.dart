import 'package:cards/models/card/card.dart';

class CardUtils {
  static CardProvider getProviderFromNumber(String number) {
    // Remove any spaces or dashes from the card number
    final cleanNumber = number.replaceAll(RegExp(r'[\s-]'), '');

    // RuPay (starts with 60, 65, 81, 82, 508)
    if (RegExp(r'^(60|65|81|82|508)').hasMatch(cleanNumber) &&
        (cleanNumber.length >= 16 && cleanNumber.length <= 19)) {
      return CardProvider.rupay;
    }

    // Visa (starts with 4)
    if (RegExp(r'^4').hasMatch(cleanNumber) &&
        (cleanNumber.length == 13 ||
            cleanNumber.length == 16 ||
            cleanNumber.length == 19)) {
      return CardProvider.visa;
    }

    // Mastercard (starts with 51-55 or 2221-2720)
    if ((RegExp(r'^(51|52|53|54|55)').hasMatch(cleanNumber) ||
            RegExp(r'^(222[1-9]|22[3-9]\d|2[3-6]\d{2}|27[0-1]\d|2720)')
                .hasMatch(cleanNumber)) &&
        cleanNumber.length == 16) {
      return CardProvider.mastercard;
    }

    // American Express (starts with 34 or 37)
    if (RegExp(r'^(34|37)').hasMatch(cleanNumber) && cleanNumber.length == 15) {
      return CardProvider.amex;
    }

    // Discover (starts with 6011, 622126-622925, 644-649, 65)
    if ((RegExp(r'^6011').hasMatch(cleanNumber) ||
            RegExp(r'^(622126|622127|622128|622129|62213|62214|62215|62216|62217|62218|62219|6222|6223|6224|6225|6226|6227|6228|6229)')
                .hasMatch(cleanNumber) ||
            RegExp(r'^(644|645|646|647|648|649|65)').hasMatch(cleanNumber)) &&
        (cleanNumber.length >= 16 && cleanNumber.length <= 19)) {
      return CardProvider.discover;
    }

    return CardProvider.unknown;
  }

  static CardType getCardTypeFromString(String type) {
    switch (type) {
      case "Debit":
        return CardType.debit;
      case "Credit":
        return CardType.credit;
      default:
        return CardType.unknown;
    }
  }

  static CardProvider getCardProviderFromString(String provider) {
    switch (provider) {
      case "VISA":
        return CardProvider.visa;
      case "MasterCard":
        return CardProvider.mastercard;
      case "Amex":
        return CardProvider.amex;
      case "Discover":
        return CardProvider.discover;
      case "RuPay":
        return CardProvider.rupay;
      default:
        return CardProvider.unknown;
    }
  }
}
