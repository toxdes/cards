import 'package:cards/models/card/card.dart';

class CardUtils {
  static CardProvider getProviderFromNumber(String number) {
    // TODO: add tests
    // Visa
    RegExp visaRegExp = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');
    // MasterCard
    RegExp masterCardRegExp = RegExp(r'^5[1-5][0-9]{14}$');
    // American Express
    RegExp amexRegExp = RegExp(r'^3[47][0-9]{13}$');
    // Discover
    RegExp discoverRegExp = RegExp(r'^6(?:011|5[0-9]{2})[0-9]{12}$');
    // RuPay
    RegExp rupayRegExp = RegExp(r'^60[0-9]{14}$');

    if (visaRegExp.hasMatch(number)) {
      return CardProvider.visa;
    }
    if (masterCardRegExp.hasMatch(number)) {
      return CardProvider.mastercard;
    }
    if (amexRegExp.hasMatch(number)) {
      return CardProvider.amex;
    }
    if (rupayRegExp.hasMatch(number)) {
      return CardProvider.rupay;
    }
    if (discoverRegExp.hasMatch(number)) {
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
