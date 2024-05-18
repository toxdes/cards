import 'package:cards/core/storage/storage.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

import 'mocks/mock_storage.dart';

void main() {
  setUp(() {});
  tearDown(() async {
    Storage storage = MockStorage();
    await storage.delete(key: CardListModelStorageKeys.testStorage);
  });

  test('raises exception when adding same card number twice', () {
    CardListModel list = CardListModel(
        storageKey: CardListModelStorageKeys.testStorage,
        storage: MockStorage());
    CardModel c = CardModelFactory.random();
    expect(() {
      list.add(c);
      list.add(c);
      return list.getAll().length == 1;
    },
        throwsA(predicate((e) =>
            e is CardListModelException &&
            e.errorCode == CLMErrorCodes.notUnique)));
  });

  test('raises exception when removing a card that doesn\'t exist', () {
    WidgetsFlutterBinding.ensureInitialized();

    CardListModel list = CardListModel(
        storageKey: CardListModelStorageKeys.testStorage,
        storage: MockStorage());
    CardModel c = CardModelFactory.random();

    expect(() {
      list.add(c);
      CardModel c1 = CardModelFactory.random();
      list.remove(c1);
    },
        throwsA(predicate((e) =>
            e is CardListModelException &&
            e.errorCode == CLMErrorCodes.doesNotExist)));
  });

  test('raises exception when removing a card from empty list', () {
    CardListModel list = CardListModel(
        storageKey: CardListModelStorageKeys.testStorage,
        storage: MockStorage());
    expect(() {
      CardModel c1 = CardModelFactory.random();
      list.remove(c1);
    },
        throwsA(predicate((e) =>
            e is CardListModelException &&
            e.errorCode == CLMErrorCodes.doesNotExist)));
  });

  test('removes item correctly.', () {
    CardListModel list = CardListModel(
        storageKey: CardListModelStorageKeys.testStorage,
        storage: MockStorage());
    expect(() {
      assert(list.getAll().isEmpty);
      CardModel c1 = CardModelFactory.random();
      CardModel c2 = CardModelFactory.random();
      CardModel c3 = CardModelFactory.random();
      list.add(c1);
      assert(list.getAll().length == 1);
      list.add(c2);
      assert(list.getAll().length == 2);
      list.remove(c2);
      assert(list.getAll().length == 1);
      list.add(c3);
      assert(list.getAll().length == 2);
      list.remove(c1);
      assert(list.getAll().length == 1);
      list.remove(c3);
      assert(list.getAll().isEmpty);
    }, returnsNormally);
  });

  test('cardlist_json_encoder works correctly', () async {
    CardListModel cardsModel = CardListModel(
        storageKey: CardListModelStorageKeys.testStorage,
        storage: MockStorage());
    CardModel c1 = CardModelFactory.random();
    CardModel c2 = CardModelFactory.random();
    CardModel c3 = CardModelFactory.random();
    cardsModel.add(c1);
    cardsModel.add(c2);
    cardsModel.add(c3);
    await cardsModel.save();
    CardListModel decodedCardsModel = CardListModel(
        storageKey: CardListModelStorageKeys.testStorage,
        storage: MockStorage());
    await decodedCardsModel.readFromStorage();
    List<CardModel> cards = cardsModel.getAll();
    List<CardModel> decodedCards =
        (await cardsModel.readFromStorage()).getAll();
    assert(cards.length == decodedCards.length);
    for (int i = 0; i < cards.length; ++i) {
      assert(cards[i].equals(decodedCards[i]));
    }
  });
}
