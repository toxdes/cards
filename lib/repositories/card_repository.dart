import 'dart:collection';

import 'package:cards/core/diff/diff_result.dart';
import 'package:cards/core/encoder/encoder.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/repositories/card_repository_json_encoder.dart';
import 'package:cards/core/storage/storage.dart';

// Error codes for card repository operations
class CardRepositoryErrorCodes {
  static const int notUnique = 0x100;
  static const int doesNotExist = 0x101;
}

class CardRepositoryException implements Exception {
  final String message;
  final int errorCode;

  CardRepositoryException(this.errorCode, this.message);

  @override
  String toString() {
    return '[CardRepositoryException] Error $errorCode: $message';
  }
}

class CardRepositoryStorageKeys {
  static const mainStorage = "cards";
  static const testStorage = "cards-tests";
}

enum Recency { oursIsRecent, theirsIsRecent }

class CardRepositoryDiffResult extends DiffResult {
  final int changed;
  HashMap<String, Recency> recency = HashMap();

  CardRepositoryDiffResult(
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

/// Repository for managing card persistence and operations
class CardRepository {
  CardRepository({
    required this.storageKey,
    required this.storage,
  });

  final List<CardModel> _cards = [];
  final Set<String> _cardNumbers = {};
  final String storageKey;
  final Storage storage;
  final Encoder encoder = CardRepositoryJsonEncoder();

  /// Add a card to the repository
  void add(CardModel card) {
    if (_cardNumbers.contains(card.getNumber())) {
      throw CardRepositoryException(CardRepositoryErrorCodes.notUnique,
          "Cannot add card, card number is not unique.");
    }
    _cards.add(card);
    _cardNumbers.add(card.getNumber());
  }

  /// Remove a card from the repository
  void remove(CardModel card) {
    if (!_cardNumbers.contains(card.getNumber())) {
      throw CardRepositoryException(CardRepositoryErrorCodes.doesNotExist,
          "Cannot remove card, no such card.");
    }
    _cardNumbers.remove(card.getNumber());
    _cards.remove(card);
  }

  void removeAll() {
    _cardNumbers.clear();
    _cards.clear();
  }

  /// Get all cards as immutable list
  UnmodifiableListView<CardModel> getAll() {
    return UnmodifiableListView(_cards);
  }

  /// Get number of cards
  int get length => _cards.length;

  /// Save all cards to storage
  Future<void> save() async {
    await storage.write(key: storageKey, value: toJson());
  }

  /// Clear all cards from storage
  void clearStorage() {
    storage.delete(key: storageKey);
  }

  /// Load all cards from storage
  Future<void> readFromStorage() async {
    String? dataJson = await storage.read(key: storageKey);
    CardRepository decoded = _decodeFromJson(dataJson ?? "[]");
    _cardNumbers.clear();
    _cards.clear();
    decoded.getAll().forEach((card) {
      _cardNumbers.add(card.getNumber());
      _cards.add(card);
    });
  }

  /// Export cards as JSON string
  String toJson() {
    return encoder.encode(this);
  }

  /// Check equality with another repository
  bool equals(CardRepository other) {
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

  /// Get diff between this repository and another
  CardRepositoryDiffResult getDiff(CardRepository other) {
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

    return CardRepositoryDiffResult(
        added: added, changed: changed, removed: removed);
  }

  /// Decode JSON string into repository
  CardRepository _decodeFromJson(String json) {
    // Using the encoder which handles CardRepository format
    // This maintains backward compatibility
    final decoded = encoder.decode(json);
    final repo = CardRepository(storageKey: storageKey, storage: storage);
    decoded.getAll().forEach((card) {
      repo._cards.add(card);
      repo._cardNumbers.add(card.getNumber());
    });
    return repo;
  }

  @override
  String toString() {
    return toJson();
  }
}
