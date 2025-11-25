import 'package:cards/core/db/model.dart';
import 'package:cards/models/card/card_json_encoder.dart';
import 'package:cards/utils/card_utils.dart';
import 'package:cards/utils/string_utils.dart';

class CardModel extends Model {
  CardModel() : super(schemaVersion: 4);

  /// Creates an empty CardModel with the specified schema version.
  /// Used internally by migrations to instantiate models at specific schema versions.
  CardModel.fromSchema(int schemaVersion) : super(schemaVersion: schemaVersion);

  CardType type = CardType.unknown;
  CardProvider provider = CardProvider.unknown;
  CardModelJsonEncoder encoder = CardModelJsonEncoder();
  String? title;
  String? number;
  String? cvv;
  String? expiry;
  String? ownerName;
  String _numberView = "";
  String _expiryView = "";
  String? billingCycle;
  int usedCount = 0;

  DateTime? createdAt;
  DateTime? updatedAt;

  DateTime? getCreatedAt() => createdAt;
  DateTime? getUpdatedAt() => updatedAt;

  void setUpdatedAt(DateTime? updatedAt) {
    this.updatedAt = updatedAt;
  }

  void setCreatedAt(DateTime? createdAt) {
    this.createdAt = createdAt;
  }

  void setBillingCycle(String? billingCycle) {
    this.billingCycle = billingCycle;
  }

  String? getBillingCycle() {
    return billingCycle;
  }

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

  String getMaskedNumberView() {
    StringBuffer sb = StringBuffer();
    int haveTo = 12;
    String maskChar = "X";
    for (int i = 0; i < _numberView.length; ++i) {
      final String c = _numberView[i];
      if (c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= '9'.codeUnitAt(0) &&
          haveTo > 0) {
        sb.write(maskChar);
        --haveTo;
      } else {
        sb.write(c);
      }
    }
    return sb.toString();
  }

  String getCVV() {
    return cvv ?? "";
  }

  String getMaskedCVV() {
    StringBuffer sb = StringBuffer();
    int haveTo = 3;
    String maskChar = '*';
    String cvvValue = cvv ?? "";
    for (int i = 0; i < cvvValue.length; ++i) {
      final String c = cvvValue[i];
      if (c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= '9'.codeUnitAt(0) &&
          haveTo > 0) {
        sb.write(maskChar);
      } else {
        sb.write(c);
      }
    }
    return sb.toString();
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

  int getUsedCount() {
    return usedCount;
  }

  void incrementUsedCount() {
    usedCount++;
  }

  void _updateProvider() {
    provider = CardUtils.getProviderFromNumber(number ?? "");
  }

  @override
  String toString() {
    return toJson();
  }

  String toJson() {
    return encoder.encode(this);
  }

  bool equals(CardModel other) {
    // FIXME: overload == operator and hashcode instead of using this method
    return type == other.type &&
        provider == other.provider &&
        title == other.title &&
        number == other.number &&
        cvv == other.cvv &&
        expiry == other.expiry &&
        ownerName == other.ownerName;
  }
}

enum CardType { debit, credit, unknown }

enum CardProvider { visa, mastercard, amex, discover, rupay, unknown }
