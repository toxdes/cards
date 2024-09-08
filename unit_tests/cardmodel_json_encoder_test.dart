import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/card_json_encoder.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  test('encoder-decoder works correctly for valid data', () {
    CardModel card = CardModelFactory.random();
    CardModelJsonEncoder encoder = CardModelJsonEncoder();
    // encode
    String encodedCard = encoder.encode(card);
    // decode
    CardModel decodedCard = encoder.decode(encodedCard);
    // compare
    assert(card.equals(decodedCard));
  });

  test('decoder throws for invalid json', () {
    String cardJson = "{}";
    CardModelJsonEncoder encoder = CardModelJsonEncoder();
    expect(() {
      encoder.decode(cardJson);
    }, throwsA(predicate((e) {
      return true;
    })));
  });
}
