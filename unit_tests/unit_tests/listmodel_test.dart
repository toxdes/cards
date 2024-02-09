import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:test/test.dart';

void main() {
  test('Should raise exception when adding same card number twice', () {
    CardListModel list = CardListModel();
    CardModel c = CardModelFactory.random();
    expect(() {
      list.add(c);
      list.add(c);
      return list.getAll().length == 1;
    },
        throwsA(predicate((e) =>
            e is CardListModelException &&
            e.errorCode == CLMErrorCodes.notUnique)));
  });

  test('Should raise exception when removing a card that doesn\'t exist', () {
    CardListModel list = CardListModel();
    CardModel c = CardModelFactory.random();

    expect(() {
      list.add(c);
      CardModel c1 = CardModelFactory.random();
      list.remove(c1);
    },
        throwsA(predicate((e) =>
            e is CardListModelException &&
            e.errorCode == CLMErrorCodes.doesNotExist)));
  });

  test('Should raise exception when removing a card from empty list', () {
    CardListModel list = CardListModel();
    expect(() {
      CardModel c1 = CardModelFactory.random();
      list.remove(c1);
    },
        throwsA(predicate((e) =>
            e is CardListModelException &&
            e.errorCode == CLMErrorCodes.doesNotExist)));
  });

  test('Should remove item correctly.', () {
    CardListModel list = CardListModel();
    expect(() {
      assert(list.getAll().isEmpty);
      CardModel c1 = CardModelFactory.random();
      CardModel c2 = CardModelFactory.random();
      CardModel c3 = CardModelFactory.random();
      list.add(c1);
      assert(list.getAll().length == 1);
      list.add(c2);
      assert(list.getAll().length == 2);
      list.remove(c2);
      assert(list.getAll().length == 1);
      list.add(c3);
      assert(list.getAll().length == 2);
      list.remove(c1);
      assert(list.getAll().length == 1);
      list.remove(c3);
      assert(list.getAll().isEmpty);
    }, returnsNormally);
  });
}
