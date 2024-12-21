import 'dart:convert';

import 'package:cards/core/encoder/encoder.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:cards/utils/secure_storage.dart';

class CardListModelJsonEncoder implements Encoder<CardListModel, String> {
  @override
  CardListModel decode(String encodedInput) {
    List<dynamic> cardsData = jsonDecode(encodedInput) as List<dynamic>;

    CardListModel result = CardListModel(
        storageKey: CardListModelStorageKeys.mainStorage,
        storage: const SecureStorage());
    for (int i = 0; i < cardsData.length; ++i) {
      CardModel c = CardModelFactory.fromJson(jsonEncode(cardsData[i]));
      result.add(c);
    }
    return result;
  }

  @override
  String encode(CardListModel input) {
    StringBuffer buf = StringBuffer();
    List<CardModel> cards = input.getAll();
    buf.write('[');
    for (int i = 0; i < cards.length; ++i) {
      buf.write(cards[i].toJson());
      if (i != cards.length - 1) buf.write(',');
    }
    buf.write(']');
    String items = buf.toString();
    return items;
  }
}
