import 'dart:math';

class CardModel {
  CardType cardType;
  CardProvider provider;
  String cardName;
  String number;
  String cvv;
  String expiry;
  String ownerName;

  static final Random rnd = Random();

  CardModel(this.cardType, this.provider, this.cardName, this.number, this.cvv,
      this.expiry, this.ownerName);

  static T _pickRandom<T>(List<T> items) {
    int index = rnd.nextInt(items.length);
    return items[index];
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

    const cardNames = <String>[
      "Amazon pay ICICI credit card",
      "Flipkart Axis card",
      "One card",
      "SBI debit",
      "HDFC regalia",
      "Axis Neo",
      "IndianOil fuel",
    ];
    String cardName = _pickRandom<String>(cardNames);

    return CardModel(
        cardType, provider, cardName, number, cvv, expiry, ownerName);
  }
}

enum CardType { debit, credit }

enum CardProvider { visa, rupay, mastercard }
