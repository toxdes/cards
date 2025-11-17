import 'package:cards/core/storage/storage.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/repositories/card_repository.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

import 'mocks/mock_storage.dart';

void main() {
  setUp(() {});
  tearDown(() async {
    Storage storage = MockStorage();
    await storage.delete(key: CardRepositoryStorageKeys.testStorage);
  });

  test('raises exception when adding same card number twice', () {
    CardRepository list = CardRepository(
        storageKey: CardRepositoryStorageKeys.testStorage,
        storage: MockStorage());
    CardModel c = CardModelFactory.random();
    expect(() {
      list.add(c);
      list.add(c);
      return list.getAll().length == 1;
    },
        throwsA(predicate((e) =>
            e is CardRepositoryException &&
            e.errorCode == CardRepositoryErrorCodes.notUnique)));
  });

  test('raises exception when removing a card that doesn\'t exist', () {
    WidgetsFlutterBinding.ensureInitialized();

    CardRepository list = CardRepository(
        storageKey: CardRepositoryStorageKeys.testStorage,
        storage: MockStorage());
    CardModel c = CardModelFactory.random();

    expect(() {
      list.add(c);
      CardModel c1 = CardModelFactory.random();
      list.remove(c1);
    },
        throwsA(predicate((e) =>
            e is CardRepositoryException &&
            e.errorCode == CardRepositoryErrorCodes.doesNotExist)));
  });

  test('raises exception when removing a card from empty list', () {
    CardRepository list = CardRepository(
        storageKey: CardRepositoryStorageKeys.testStorage,
        storage: MockStorage());
    expect(() {
      CardModel c1 = CardModelFactory.random();
      list.remove(c1);
    },
        throwsA(predicate((e) =>
            e is CardRepositoryException &&
            e.errorCode == CardRepositoryErrorCodes.doesNotExist)));
  });

  test('removes item correctly.', () {
    CardRepository list = CardRepository(
        storageKey: CardRepositoryStorageKeys.testStorage,
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
    CardRepository cardsModel = CardRepository(
        storageKey: CardRepositoryStorageKeys.testStorage,
        storage: MockStorage());
    CardModel c1 = CardModelFactory.random();
    CardModel c2 = CardModelFactory.random();
    CardModel c3 = CardModelFactory.random();
    cardsModel.add(c1);
    cardsModel.add(c2);
    cardsModel.add(c3);
    await cardsModel.save();
    CardRepository decodedCardsModel = CardRepository(
        storageKey: CardRepositoryStorageKeys.testStorage,
        storage: MockStorage());
    await decodedCardsModel.readFromStorage();
    List<CardModel> cards = cardsModel.getAll();
    await cardsModel.readFromStorage();
    List<CardModel> decodedCards = cardsModel.getAll();
    assert(cards.length == decodedCards.length);
    for (int i = 0; i < cards.length; ++i) {
      assert(cards[i].equals(decodedCards[i]));
    }
  });

  test('getDiff() with both empty', () {
    CardRepository ours = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    CardRepository theirs = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    CardRepositoryDiffResult diffResult = ours.getDiff(theirs);

    expect(diffResult.added, 0);
    expect(diffResult.removed, 0);
    expect(diffResult.changed, 0);
  });

  test('getDiff() with both equal', () {
    CardRepository ours = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    CardRepository theirs = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    CardModel c1 = CardModelFactory.random();
    CardModel c2 = CardModelFactory.random();
    CardModel c3 = CardModelFactory.random();

    ours.add(c1);
    ours.add(c2);
    ours.add(c3);

    theirs.add(c1);
    theirs.add(c2);
    theirs.add(c3);
    CardRepositoryDiffResult diffResult = ours.getDiff(theirs);

    expect(diffResult.added, 0);
    expect(diffResult.removed, 0);
    expect(diffResult.changed, 0);
  });

  test('getDiff() with incoming-deletion', () {
    CardRepository ours = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    CardRepository theirs = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    ours.add(CardModelFactory.random());
    ours.add(CardModelFactory.random());
    ours.add(CardModelFactory.random());

    CardRepositoryDiffResult diffResult = ours.getDiff(theirs);

    expect(diffResult.added, 0);
    expect(diffResult.removed, 3);
    expect(diffResult.changed, 0);
  });

  test('getDiff() with incoming-addition', () {
    CardRepository ours = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    CardRepository theirs = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    theirs.add(CardModelFactory.random());
    theirs.add(CardModelFactory.random());
    theirs.add(CardModelFactory.random());

    CardRepositoryDiffResult diffResult = ours.getDiff(theirs);

    expect(diffResult.added, 3);
    expect(diffResult.removed, 0);
    expect(diffResult.changed, 0);
  });

  test('getDiff() with incoming-change', () {
    CardRepository ours = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    CardRepository theirs = CardRepository(
        storage: MockStorage(),
        storageKey: CardRepositoryStorageKeys.testStorage);

    // add a random card to ours
    CardModel c1 = CardModelFactory.random();
    ours.add(c1);

    // create a copy c2 of c1, with cvv changed, and add it to theirs
    CardModel c2 = CardModelFactory.fromJson(c1.toJson());
    c2.setCVV("200");
    theirs.add(c2);

    // add another random card c2 to theirs
    c2 = CardModelFactory.random();
    theirs.add(c2);

    // create a copy c1 of c2, with ownerName changed, and add it to ours
    c1 = CardModelFactory.fromJson(c2.toJson());
    c1.setOwnerName("meow");
    ours.add(c1);

    // ours should have 2 cards, theirs should have 2 cards, and both are different in theirs, so diff-result should show changed cards as 2
    CardRepositoryDiffResult diffResult = ours.getDiff(theirs);

    expect(diffResult.added, 0);
    expect(diffResult.removed, 0);
    expect(diffResult.changed, 2);
  });
}
