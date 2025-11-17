import 'dart:convert';

import 'package:cards/core/encoder/encoder.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/repositories/card_repository.dart';
import 'package:cards/utils/secure_storage.dart';

class CardRepositoryJsonEncoder implements Encoder<CardRepository, String> {
  @override
  CardRepository decode(String encodedInput) {
    List<dynamic> cardsData = jsonDecode(encodedInput) as List<dynamic>;

    CardRepository result = CardRepository(
        storageKey: CardRepositoryStorageKeys.mainStorage,
        storage: const SecureStorage());
    for (int i = 0; i < cardsData.length; ++i) {
      CardModel c = CardModelFactory.fromJson(jsonEncode(cardsData[i]));
      result.add(c);
    }
    return result;
  }

  @override
  String encode(CardRepository input) {
    List<CardModel> cards = input.getAll();
    List<Map<String, dynamic>> cardsJson = cards
        .map((card) => jsonDecode(card.toJson()) as Map<String, dynamic>)
        .toList();
    return jsonEncode(cardsJson);
  }
}
