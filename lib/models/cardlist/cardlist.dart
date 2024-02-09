import 'dart:collection';

import 'package:cards/models/card/card.dart';

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

class CardListModel {
  final List<CardModel> _cards = [];
  final Set<String> _cardNumbers = {};

  void add(CardModel c) {
    if (_cardNumbers.contains(c.getNumber())) {
      throw CardListModelException(CLMErrorCodes.notUnique,
          "Cannot add card, card number is not unique.");
    }
    _cards.add(c);
    _cardNumbers.add(c.getNumber());
  }

  void remove(CardModel c) {
    if (!_cardNumbers.contains(c.getNumber())) {
      throw CardListModelException(
          CLMErrorCodes.doesNotExist, "Cannot remove card, no such card.");
    }
    _cardNumbers.remove(c.getNumber());
    _cards.remove(c);
  }

  UnmodifiableListView<CardModel> getAll() {
    return UnmodifiableListView(_cards);
  }

  void saveToStorage() {}

  void loadFromStorage() {}
}
