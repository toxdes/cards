import 'dart:collection';
import 'dart:convert';

import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final _storage = const FlutterSecureStorage();
  static const cardListStorageKey = "cards";
  int length = 0;

  void add(CardModel c, {bool sync = false}) {
    if (_cardNumbers.contains(c.getNumber())) {
      throw CardListModelException(CLMErrorCodes.notUnique,
          "Cannot add card, card number is not unique.");
    }
    _cards.add(c);
    _cardNumbers.add(c.getNumber());
    _updateLength();
    if (sync) writeToStorage();
  }

  void remove(CardModel c, {bool sync = false}) {
    if (!_cardNumbers.contains(c.getNumber())) {
      throw CardListModelException(
          CLMErrorCodes.doesNotExist, "Cannot remove card, no such card.");
    }
    _cardNumbers.remove(c.getNumber());
    _cards.remove(c);
    _updateLength();
    if (sync) writeToStorage();
  }

  UnmodifiableListView<CardModel> getAll() {
    return UnmodifiableListView(_cards);
  }

  void _updateLength() {
    length = _cards.length;
  }

  Future<void> writeToStorage() async {
    await _storage.write(key: cardListStorageKey, value: toJson());
  }

  void clearStorage() {
    _storage.delete(key: cardListStorageKey);
  }

  Future<CardListModel> readFromStorage() async {
    String? dataJson = await _storage.read(key: cardListStorageKey);
    List<dynamic> cardsData = jsonDecode(dataJson ?? "[]");
    CardListModel result = CardListModel();
    for (int i = 0; i < cardsData.length; ++i) {
      CardModel c =
          CardModelFactory.fromJson(cardsData[i] as Map<String, dynamic>);
      result.add(c);
    }
    return result;
  }

  @override
  String toString() {
    return toJson();
  }

  String toJson() {
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < _cards.length; ++i) {
      buf.write(_cards[i].toJson());
      if (i != _cards.length - 1) buf.write(',');
    }
    String items = buf.toString();
    return """
[$items]
""";
  }
}
