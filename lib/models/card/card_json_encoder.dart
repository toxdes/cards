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

    // Handle both old (string) and new (int) formats for backward compatibility
    int? schemaVersion;
    final schemaVersionValue = record['schemaVersion'];
    if (schemaVersionValue is int) {
      schemaVersion = schemaVersionValue;
    } else if (schemaVersionValue is String) {
      schemaVersion = int.tryParse(schemaVersionValue);
    }
    schemaVersion ??= 0;

    int? createdAt;
    final createdAtValue = record['createdAt'];
    if (createdAtValue is int) {
      createdAt = createdAtValue;
    } else if (createdAtValue is String) {
      createdAt = int.tryParse(createdAtValue);
    }

    int? updatedAt;
    final updatedAtValue = record['updatedAt'];
    if (updatedAtValue is int) {
      updatedAt = updatedAtValue;
    } else if (updatedAtValue is String) {
      updatedAt = int.tryParse(updatedAtValue);
    }

    String? billingCycle = record['billingCycle'];

    CardNumberType cardNumberType =
        CardUtils.getCardNumberTypeFromString(record['cardNumberType'] ?? "");

    int usedCount = 0;
    final usedCountValue = record['usedCount'];
    if (usedCountValue is int) {
      usedCount = usedCountValue;
    } else if (usedCountValue is String) {
      usedCount = int.tryParse(usedCountValue) ?? 0;
    }

    CardModel card = CardModelFactory.fromSchema(schemaVersion);

    card
      ..setNumber((record['number'] ?? '') as String)
      ..setProvider(CardUtils.getCardProviderFromString(
          (record['provider'] ?? 'Unknown') as String))
      ..setCVV((record['cvv'] ?? '') as String)
      ..setExpiry((record['expiry'] ?? '') as String)
      ..setCardType(CardUtils.getCardTypeFromString(
          (record['type'] ?? 'Unknown') as String))
      ..setTitle((record['title'] ?? '') as String)
      ..setCardNumberType(cardNumberType)
      ..setOwnerName((record['ownerName'] ?? '') as String);
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
    card.usedCount = usedCount;
    return card;
  }

  @override
  String encode(CardModel c) {
    final json = <String, dynamic>{
      'schemaVersion': c.schemaVersion,
      'title': c.title,
      'number': c.number,
      'provider': c.getProviderView(),
      'cvv': c.cvv,
      'type': c.getCardTypeView(),
      'expiry': c.expiry,
      'ownerName': c.ownerName,
      'createdAt': c.createdAt?.toUtc().microsecondsSinceEpoch,
      'updatedAt': c.updatedAt?.toUtc().microsecondsSinceEpoch,
      'billingCycle': c.getBillingCycle(),
      'usedCount': c.usedCount,
      'cardNumberType': c.getCardNumberTypeView(),
    };
    return jsonEncode(json);
  }
}
