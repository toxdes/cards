import 'package:cards/utils/string_utils.dart';

class CardModel {
  CardType? type;
  CardProvider? provider;
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
    return type ?? CardType.credit;
  }

  CardProvider getProvider() {
    return provider ?? CardProvider.visa;
  }

  String getProviderView() {
    return provider == CardProvider.visa
        ? "VISA"
        : provider == CardProvider.rupay
            ? "RuPay"
            : "Mastercard";
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
}

enum CardType { debit, credit }

enum CardProvider { visa, rupay, mastercard }
