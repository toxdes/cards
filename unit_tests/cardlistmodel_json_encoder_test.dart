import 'package:cards/repositories/card_repository.dart';
import 'package:cards/repositories/card_repository_json_encoder.dart';
import 'package:test/test.dart';

import 'mocks/mock_storage.dart';

void main() {
  test('encoder-decoder works correctly for valid data', () {
    CardRepository cards = CardRepository(
        storageKey: CardRepositoryStorageKeys.testStorage,
        storage: MockStorage());
    CardRepositoryJsonEncoder encoder = CardRepositoryJsonEncoder();
    // encode
    String encodedCards = encoder.encode(cards);
    // decode
    CardRepository decodedCards = encoder.decode(encodedCards);
    // compare
    assert(cards.equals(decodedCards));
  });

  test('decoder throws for invalid json', () {
    String cardJson = "{}";
    CardRepositoryJsonEncoder encoder = CardRepositoryJsonEncoder();
    expect(() {
      encoder.decode(cardJson);
    }, throwsA(predicate((e) {
      return true;
    })));
  });
}
