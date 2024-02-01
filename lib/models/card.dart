import 'dart:math';

class CardModel {
  CardType cardType;
  CardProvider provider;
  String cardName;
  String number;
  String cvv;
  String expiry;
  String ownerName;
  Random rnd = Random();
  CardModel(this.cardType, this.provider, this.cardName, this.number, this.cvv,
      this.expiry, this.ownerName);

  T pickRandom<T>(List<T> items) {
    int index = rnd.nextInt(items.length);
    return items[index];
  }

  void randomize() {
    const firstNames = <String>[
      "Alice",
      "Bill",
      "Charlie",
      "Donald",
      "Elon",
      "Jeff"
    ];
    const lastNames = <String>["Trump", "Gates", "Bezos", "Musk"];

    ownerName =
        "${pickRandom<String>(firstNames)} ${pickRandom<String>(lastNames)}";

    number = "";
    for (var i = 1; i <= 16; ++i) {
      number += rnd.nextInt(10).toString();
      if (i % 4 == 0 && i != 1 && i != 16) number += " ";
    }
    cvv = (100 + rnd.nextInt(900)).toString();
    cardType = pickRandom<CardType>(CardType.values);

    provider = pickRandom<CardProvider>(CardProvider.values);

    const cardNames = <String>[
      "Amazon pay ICICI credit card",
      "Flipkart Axis card",
      "One card",
      "SBI debit",
      "HDFC regalia",
      "Axis Neo",
      "IndianOil fuel",
    ];
    cardName = pickRandom<String>(cardNames);
  }
}

enum CardType { debit, credit }

enum CardProvider { visa, rupay, mastercard }
