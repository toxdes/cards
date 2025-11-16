import 'dart:collection';

import 'package:cards/core/db/model.dart';
import 'package:cards/core/diff/diff_result.dart';
import 'package:cards/core/encoder/encoder.dart';
import 'package:cards/core/storage/storage.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/cardlist/cardlist_json_encoder.dart';
import 'package:cards/utils/secure_storage.dart';

// CLM ✊ -> CardListModel
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

class CardListModelStorageKeys {
  static const mainStorage = "cards";
  static const testStorage = "cards-tests";
}

enum Recency { oursIsRecent, theirsIsRecent }

class CardListModelDiffResult extends DiffResult {
  final int changed;
  // TODO: implement recency after createdAt is introduced to CardModel
  HashMap<String, Recency> recency = HashMap();

  CardListModelDiffResult(
      {required super.added, required super.removed, required this.changed});

  @override
  String toString() {
    StringBuffer buf = StringBuffer();
    buf.write(
        "DiffResult<added = $added, removed = $removed, changed = $changed>");
    buf.write("\n");
    recency.forEach((String key, Recency recency) {
      buf.write("\t\t");
      buf.write("$key -> ");
      buf.write(recency == Recency.oursIsRecent
          ? "Ours is latest"
          : "Theirs is latest");
      buf.write('\n');
    });
    return buf.toString();
  }
}

class CardListModel extends Model {
  CardListModel(
      {required this.storageKey, required this.storage, this.onUpdate})
      : super(schemaVersion: 1);

  final List<CardModel> _cards = [];
  final Set<String> _cardNumbers = {};
  final String storageKey;
  final Storage storage;
  Function? onUpdate;
  // should encoder be private?
  final Encoder encoder = CardListModelJsonEncoder();
  int length = 0;
  static CardListModel? _instance;

  static CardListModel the() {
    _instance ??= CardListModel(
        storageKey: CardListModelStorageKeys.mainStorage,
        storage: const SecureStorage());
    return _instance!;
  }

  static void setThe(CardListModel newModel) {
    _instance = newModel;
    if (_instance!.onUpdate != null) {
      _instance!.onUpdate!();
    }
  }

  void add(CardModel c) {
    if (_cardNumbers.contains(c.getNumber())) {
      throw CardListModelException(CLMErrorCodes.notUnique,
          "Cannot add card, card number is not unique.");
    }
    _cards.add(c);
    _cardNumbers.add(c.getNumber());
    _updateLength();
    if (onUpdate != null) {
      onUpdate!(this);
    }
  }

  void remove(CardModel c, {bool sync = false}) {
    if (!_cardNumbers.contains(c.getNumber())) {
      throw CardListModelException(
          CLMErrorCodes.doesNotExist, "Cannot remove card, no such card.");
    }
    _cardNumbers.remove(c.getNumber());
    _cards.remove(c);
    _updateLength();
    if (onUpdate != null) {
      onUpdate!(this);
    }
  }

  void setUpdateListener(Function onUpdate) {
    this.onUpdate = onUpdate;
  }

  UnmodifiableListView<CardModel> getAll() {
    return UnmodifiableListView(_cards);
  }

  void _updateLength() {
    length = _cards.length;
  }

  Future<void> _writeToStorage() async {
    await storage.write(key: storageKey, value: toJson());
  }

  Future<void> save() async {
    await _writeToStorage();
  }

  void clearStorage() {
    storage.delete(key: storageKey);
  }

  Future<CardListModel> readFromStorage() async {
    String? dataJson = await storage.read(key: storageKey);
    CardListModel decodedCards = encoder.decode(dataJson ?? "[]");
    _cardNumbers.clear();
    _cards.clear();
    decodedCards.getAll().forEach((card) {
      _cardNumbers.add(card.getNumber());
      _cards.add(card);
    });

    _updateLength();
    if (onUpdate != null) {
      onUpdate!(this);
    }
    return this;
  }

  @override
  String toString() {
    return toJson();
  }

  String toJson() {
    return encoder.encode(this);
  }

  bool equals(CardListModel other) {
    if (other.length != length) {
      return false;
    }
    UnmodifiableListView<CardModel> otherCards = other.getAll();
    for (int i = 0; i < length; ++i) {
      if (!_cards[i].equals(otherCards[i])) {
        return false;
      }
    }
    return true;
  }

  CardListModelDiffResult getDiff(CardListModel other) {
    int added = 0, changed = 0, removed = 0;
    UnmodifiableListView<CardModel> ours = getAll();
    UnmodifiableListView<CardModel> theirs = other.getAll();

    // count cards that were not present in `other`
    for (int i = 0; i < ours.length; ++i) {
      CardModel c1 = ours[i];
      bool exists = false;
      for (int j = 0; j < theirs.length; ++j) {
        CardModel c2 = theirs[j];
        if (c1.getNumber() == c2.getNumber()) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        ++removed;
      }
    }

    // count cards that were added & changed in `other`
    for (int i = 0; i < theirs.length; ++i) {
      CardModel c1 = theirs[i];
      bool exists = false;
      bool isChanged = false;
      for (int j = 0; j < ours.length; ++j) {
        CardModel c2 = ours[j];
        if (c1.getNumber() == c2.getNumber()) {
          exists = true;
          isChanged = !c1.equals(c2);
          break;
        }
      }
      if (!exists) {
        ++added;
        continue;
      }
      if (isChanged) {
        ++changed;
      }
    }

    CardListModelDiffResult res = CardListModelDiffResult(
        added: added, changed: changed, removed: removed);
    return res;
  }
}
