import 'dart:math';

import 'package:cards/models/card/card.dart';
import 'package:cards/utils/card_utils.dart';

class CardModelFactory {
  static final Random rnd = Random();

  static T _pickRandom<T>(List<T> items) {
    int index = rnd.nextInt(items.length);
    return items[index];
  }

  static CardModel blank() {
    return CardModel();
  }

  static CardModel random() {
    const firstNames = <String>[
      "Alice",
      "Bill",
      "Charlie",
      "Donald",
      "Elon",
      "Jeff"
    ];
    const lastNames = <String>["Trump", "Gates", "Bezos", "Musk"];

    String ownerName =
        "${_pickRandom<String>(firstNames)} ${_pickRandom<String>(lastNames)}";

    String number = "";
    for (var i = 1; i <= 16; ++i) {
      number += rnd.nextInt(10).toString();
      if (i % 4 == 0 && i != 1 && i != 16) number += " ";
    }
    String cvv = (100 + rnd.nextInt(900)).toString();
    String expiry = "${1 + rnd.nextInt(12)}/${23 + rnd.nextInt(10)}";
    CardType cardType = _pickRandom<CardType>(CardType.values);

    CardProvider provider = _pickRandom<CardProvider>(CardProvider.values);

    const titles = <String>[
      "Amazon pay ICICI credit card",
      "Flipkart Axis card",
      "One card",
      "SBI debit",
      "HDFC regalia",
      "Axis Neo",
      "IndianOil fuel",
    ];
    String title = _pickRandom<String>(titles);

    return CardModelFactory.blank()
      ..setTitle(title)
      ..setNumber(number)
      ..setCVV(cvv)
      ..setExpiry(expiry)
      ..setOwnerName(ownerName)
      ..setCardType(cardType)
      ..setProvider(provider);
  }

  static CardModel fromJson(Map<String, dynamic> record) {
    CardModel card = CardModelFactory.blank();
    return card
      ..setNumber(record['number'] as String)
      ..setCVV(record['cvv'] as String)
      ..setExpiry(record['expiry'] as String)
      ..setCardType(CardUtils.getCardTypeFromString(record['type'] as String))
      ..setTitle(record['title'] as String)
      ..setOwnerName(record['ownerName'] as String);
  }
}
