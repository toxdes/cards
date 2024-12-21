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
    int? createdAt = int.tryParse(record['createdAt'] ?? "bad");
    int? updatedAt = int.tryParse(record['updatedAt'] ?? "bad");
    int? schemaVersion = int.tryParse(record['schemaVersion'] ?? "bad");
    String? billingCycle = record['billingCycle'];
    schemaVersion ??= 0;

    CardModel card = CardModelFactory.fromSchema(schemaVersion);

    card
      ..setNumber(record['number'] as String)
      ..setProvider(
          CardUtils.getCardProviderFromString(record['provider'] as String))
      ..setCVV(record['cvv'] as String)
      ..setExpiry(record['expiry'] as String)
      ..setCardType(CardUtils.getCardTypeFromString(record['type'] as String))
      ..setTitle(record['title'] as String)
      ..setOwnerName(record['ownerName'] as String);
    if (createdAt != null) {
      card.setCreatedAt(
          DateTime.fromMicrosecondsSinceEpoch(createdAt, isUtc: true));
    }
    if (updatedAt != null) {
      card.setUpdatedAt(
          DateTime.fromMicrosecondsSinceEpoch(updatedAt, isUtc: true));
    }
    if (billingCycle != null) {
      card.setBillingCycle(billingCycle);
    }
    return card;
  }

  @override
  String encode(CardModel c) {
    return """
{
  "schemaVersion":"${c.schemaVersion}",
  "title": "${c.title}",
  "number": "${c.number}",
  "provider": "${c.getProviderView()}",
  "cvv": "${c.cvv}",
  "type": "${c.getCardTypeView()}",
  "expiry": "${c.expiry}",
  "ownerName": "${c.ownerName}",
  "createdAt": ${c.createdAt == null ? 'null' : '"${c.createdAt!.toUtc().microsecondsSinceEpoch}"'},
  "updatedAt": ${c.updatedAt == null ? 'null' : '"${c.updatedAt!.toUtc().microsecondsSinceEpoch}"'},
  "billingCycle": "${c.getBillingCycle() == null ? 'null' : "${c.getBillingCycle()}"}"
}
    """;
  }
}
