import 'dart:collection';

import 'package:cards/core/encoder/encoder.dart';
import 'package:cards/core/storage/storage.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/cardlist/cardlist_json_encoder.dart';

class CLMErrorCodes {
  static const int notUnique = 0x100;
  static const int doesNotExist = 0x101;
}

class CardListModelException implements Exception {
  final String message;
  final int errorCode;
  CardListModelException(this.errorCode, this.message);
  @override
  String toString() {
    return '[CardListException] Error $errorCode: $message';
  }
}

class CardListModelStorageKeys {
  static const mainStorage = "cards";
  static const testStorage = "cards-tests";
}

class CardListModel {
  final List<CardModel> _cards = [];
  final Set<String> _cardNumbers = {};
  final String storageKey;
  final Storage storage;
  CardListModel({required this.storageKey, required this.storage});
  // should encoder be private?
  final Encoder encoder = CardListModelJsonEncoder();
  int length = 0;

  void add(CardModel c) {
    if (_cardNumbers.contains(c.getNumber())) {
      throw CardListModelException(CLMErrorCodes.notUnique,
          "Cannot add card, card number is not unique.");
    }
    _cards.add(c);
    _cardNumbers.add(c.getNumber());
    _updateLength();
  }

  void remove(CardModel c, {bool sync = false}) {
    if (!_cardNumbers.contains(c.getNumber())) {
      throw CardListModelException(
          CLMErrorCodes.doesNotExist, "Cannot remove card, no such card.");
    }
    _cardNumbers.remove(c.getNumber());
    _cards.remove(c);
    _updateLength();
  }

  UnmodifiableListView<CardModel> getAll() {
    return UnmodifiableListView(_cards);
  }

  void _updateLength() {
    length = _cards.length;
  }

  Future<void> _writeToStorage() async {
    await storage.write(key: storageKey, value: toJson());
  }

  Future<void> save() async {
    await _writeToStorage();
  }

  void clearStorage() {
    storage.delete(key: storageKey);
  }

  Future<CardListModel> readFromStorage() async {
    String? dataJson = await storage.read(key: storageKey);
    CardListModel decodedCards = encoder.decode(dataJson ?? "[]");
    _cardNumbers.clear();
    _cards.clear();
    decodedCards.getAll().forEach((card) {
      _cardNumbers.add(card.getNumber());
      _cards.add(card);
    });

    _updateLength();
    return this;
  }

  @override
  String toString() {
    return toJson();
  }

  String toJson() {
    return encoder.encode(this);
  }

  bool equals(CardListModel other) {
    if (other.length != length) {
      return false;
    }
    UnmodifiableListView<CardModel> otherCards = other.getAll();
    for (int i = 0; i < length; ++i) {
      if (!_cards[i].equals(otherCards[i])) {
        return false;
      }
    }
    return true;
  }
}
