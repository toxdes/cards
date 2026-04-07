import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/card_json_encoder.dart';
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

  test('decoder handles incomplete JSON gracefully for backward compatibility',
      () {
    String cardJson = "{}";
    CardModelJsonEncoder encoder = CardModelJsonEncoder();
    // Should not throw - handles incomplete data gracefully
    CardModel decodedCard = encoder.decode(cardJson);
    // Fields should have default values
    assert(decodedCard.getNumber().isEmpty);
    assert(!decodedCard.hasCVV());
    assert(decodedCard.getCVVOrEmpty().isEmpty);
  });

  test('decoder handles old format with string types', () {
    // Old format had everything as strings
    String oldFormatJson = '{'
        '"schemaVersion":"0",'
        '"title":"Test Card",'
        '"number":"1234567890123456",'
        '"provider":"VISA",'
        '"cvv":"123",'
        '"type":"Credit",'
        '"expiry":"12/25",'
        '"ownerName":"John Doe",'
        '"createdAt":"1699000000000000",'
        '"updatedAt":"1699000000000000",'
        '"billingCycle":"15"'
        '}';
    CardModelJsonEncoder encoder = CardModelJsonEncoder();
    CardModel decodedCard = encoder.decode(oldFormatJson);
    assert(decodedCard.schemaVersion == 0);
    assert(decodedCard.getTitle() == "Test Card");
  });

  test('encoder-decoder preserves null CVV', () {
    CardModel card = CardModelFactory.blank();
    card.setTitle("Test Card");
    card.setNumber("1234567890123456");
    card.setExpiry("12/25");
    // CVV is not set - should remain null
    assert(!card.hasCVV());
    assert(card.getCVV() == null);

    CardModelJsonEncoder encoder = CardModelJsonEncoder();
    String encodedCard = encoder.encode(card);
    CardModel decodedCard = encoder.decode(encodedCard);

    // CVV should still be null after encode/decode
    assert(!decodedCard.hasCVV());
    assert(decodedCard.getCVV() == null);
  });

  test('decoder handles empty string CVV from old backups', () {
    // Old backups may have empty string for CVV when it wasn't set
    String cardJson = '{'
        '"title":"Test Card",'
        '"number":"1234567890123456",'
        '"cvv":"",'
        '"expiry":"1225"'
        '}';
    CardModelJsonEncoder encoder = CardModelJsonEncoder();
    CardModel decodedCard = encoder.decode(cardJson);

    // Empty string CVV should be preserved
    assert(!decodedCard.hasCVV());
    assert(decodedCard.getCVV() == "");
    assert(decodedCard.getCVVOrEmpty().isEmpty);
  });

  test('decoder handles explicit null CVV in JSON', () {
    // Explicit null CVV should remain null
    String cardJson = '{'
        '"title":"Test Card",'
        '"number":"1234567890123456",'
        '"cvv":null,'
        '"expiry":"1225"'
        '}';
    CardModelJsonEncoder encoder = CardModelJsonEncoder();
    CardModel decodedCard = encoder.decode(cardJson);

    // Null CVV should be preserved
    assert(!decodedCard.hasCVV());
    assert(decodedCard.getCVV() == null);
    assert(decodedCard.getCVVOrEmpty().isEmpty);
  });
}
