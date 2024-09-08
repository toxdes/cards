import 'package:cards/models/cardlist/cardlist.dart';
import 'package:cards/models/cardlist/cardlist_json_encoder.dart';
import 'package:test/test.dart';

import 'mocks/mock_storage.dart';

void main() {
  test('encoder-decoder works correctly for valid data', () {
    CardListModel cards = CardListModel(
        storageKey: CardListModelStorageKeys.testStorage,
        storage: MockStorage());
    CardListModelJsonEncoder encoder = CardListModelJsonEncoder();
    // encode
    String encodedCards = encoder.encode(cards);
    // decode
    CardListModel decodedCards = encoder.decode(encodedCards);
    // compare
    assert(cards.equals(decodedCards));
  });

  test('decoder throws for invalid json', () {
    String cardJson = "{}";
    CardListModelJsonEncoder encoder = CardListModelJsonEncoder();
    expect(() {
      encoder.decode(cardJson);
    }, throwsA(predicate((e) {
      return true;
    })));
  });
}
