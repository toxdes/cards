import 'package:cards/utils/card_utils.dart';
import 'package:cards/utils/string_utils.dart';

class CardModel {
  CardType type = CardType.unknown;
  CardProvider provider = CardProvider.unknown;
  String? title;
  String? number;
  String? cvv;
  String? expiry;
  String? ownerName;
  String _numberView = "";
  String _expiryView = "";

  void setCardType(CardType type) {
    this.type = type;
  }

  void setProvider(CardProvider provider) {
    this.provider = provider;
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setNumber(String number) {
    this.number = StringUtils.removeAll(number, ' ');

    StringBuffer buf = StringBuffer();
    for (int i = 1; i <= number.length; ++i) {
      buf.write(number[i - 1]);
      if (i % 4 == 0 && i != 16) {
        buf.write(' ');
      }
    }
    _numberView = buf.toString();
    _updateProvider();
  }

  void setCVV(String cvv) {
    this.cvv = cvv;
  }

  void setExpiry(String expiry) {
    this.expiry = expiry;
    StringBuffer buf = StringBuffer();
    for (int i = 1; i <= expiry.length; ++i) {
      buf.write(expiry[i - 1]);
      if (i % 2 == 0 && i != 4) {
        buf.write('/');
      }
    }
    _expiryView = buf.toString();
  }

  void setOwnerName(String ownerName) {
    this.ownerName = ownerName;
  }

  CardType getCardType() {
    return type;
  }

  String getCardTypeView() {
    switch (type) {
      case CardType.debit:
        return "Debit";
      case CardType.credit:
        return "Credit";
      case CardType.unknown:
        return 'Unknown';
    }
  }

  CardProvider getProvider() {
    return provider;
  }

  String getProviderView() {
    switch (provider) {
      case CardProvider.visa:
        return "VISA";
      case CardProvider.mastercard:
        return "MasterCard";
      case CardProvider.amex:
        return "Amex";
      case CardProvider.discover:
        return "Discover";
      case CardProvider.rupay:
        return "RuPay";
      case CardProvider.unknown:
        return "Unknown";
    }
  }

  String getTitle() {
    return title ?? "";
  }

  String getNumber() {
    return number ?? "";
  }

  String getNumberView() {
    return _numberView;
  }

  String getCVV() {
    return cvv ?? "";
  }

  String getExpiry() {
    return expiry ?? "";
  }

  String getExpiryView() {
    return _expiryView;
  }

  String getOwnerName() {
    return ownerName ?? "";
  }

  void _updateProvider() {
    provider = CardUtils.getProviderFromNumber(number ?? "");
  }

  @override
  String toString() {
    return toJson();
  }

  String toJson() {
    return """
{
  "title": "$title",
  "number": "$number",
  "provider":"${getProviderView()}",
  "cvv":"$cvv",
  "type":"${getCardTypeView()}",
  "expiry":"$expiry",
  "ownerName":"$ownerName"
}
    """;
  }
}

enum CardType { debit, credit, unknown }

enum CardProvider { visa, mastercard, amex, discover, rupay, unknown }
