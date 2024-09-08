import 'dart:convert';

import 'package:cards/core/encoder/encoder.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/utils/card_utils.dart';

class CardModelJsonEncoder implements Encoder<CardModel, String> {
  @override
  CardModel decode(String encodedInput) {
    Map<String, dynamic> record =
        jsonDecode(encodedInput) as Map<String, dynamic>;
    CardModel card = CardModelFactory.blank();
    return card
      ..setNumber(record['number'] as String)
      ..setProvider(
          CardUtils.getCardProviderFromString(record['provider'] as String))
      ..setCVV(record['cvv'] as String)
      ..setExpiry(record['expiry'] as String)
      ..setCardType(CardUtils.getCardTypeFromString(record['type'] as String))
      ..setTitle(record['title'] as String)
      ..setOwnerName(record['ownerName'] as String);
  }

  @override
  String encode(CardModel c) {
    return """
{
  "title": "${c.title}",
  "number": "${c.number}",
  "provider": "${c.getProviderView()}",
  "cvv": "${c.cvv}",
  "type": "${c.getCardTypeView()}",
  "expiry": "${c.expiry}",
  "ownerName": "${c.ownerName}"
}
    """;
  }
}
