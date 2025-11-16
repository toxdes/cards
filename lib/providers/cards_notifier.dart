import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/repositories/card_repository.dart';
import 'package:cards/services/toast_service.dart';
import 'package:cards/services/sentry_service.dart';
import 'package:cards/utils/secure_storage.dart';

/// Notifier for managing cards list state
class CardsNotifier extends ChangeNotifier {
  final CardRepository _cardRepo;
  bool _loaded = false;

  CardsNotifier({CardRepository? repository})
      : _cardRepo = repository ??
            CardRepository(
              storageKey: CardRepositoryStorageKeys.mainStorage,
              storage: const SecureStorage(),
            ) {
    _initializeCards();
  }

  /// Load cards from storage on initialization
  void _initializeCards() {
    _cardRepo.readFromStorage().then((_) {
      _loaded = true;
      notifyListeners();
    }).catchError((e) {
      _loaded = false;
      notifyListeners();
    });
  }

  bool get isLoaded => _loaded;

  CardRepository get cardList => _cardRepo;

  int get cardCount => _cardRepo.length;

  UnmodifiableListView<CardModel> getAllCards() {
    return _cardRepo.getAll();
  }

  /// Add a new card with error handling and persistence
  Future<void> addCard(CardModel card) async {
    try {
      _cardRepo.add(card);
      await _cardRepo.save();
      ToastService.show(status: ToastStatus.success, message: "card saved");
      notifyListeners();
    } catch (e, stackTrace) {
      SentryService.error(e, stackTrace);
      String message = "couldn't save card";
      if (e is CardRepositoryException) {
        if (e.errorCode == CardRepositoryErrorCodes.notUnique) {
          message = "failed to save. You already have a card with same number";
        }
      }
      ToastService.show(status: ToastStatus.error, message: message);
      rethrow;
    }
  }

  /// Remove a card with error handling and persistence
  Future<void> removeCard(CardModel card) async {
    try {
      _cardRepo.remove(card);
      await _cardRepo.save();
      ToastService.show(status: ToastStatus.success, message: "card deleted");
      notifyListeners();
    } catch (e, stackTrace) {
      SentryService.error(e, stackTrace);
      String message = "couldn't delete card";
      if (e is CardRepositoryException) {
        if (e.errorCode == CardRepositoryErrorCodes.doesNotExist) {
          message = "card does not exist";
        }
      }
      ToastService.show(status: ToastStatus.error, message: message);
      rethrow;
    }
  }

  /// Load cards from storage
  Future<void> loadCards() async {
    await _cardRepo.readFromStorage();
    notifyListeners();
  }

  /// For backup/restore: restore cards from JSON string
  Future<void> restoreFromJson(String jsonString) async {
    try {
      CardRepository restored = _cardRepo.encoder.decode(jsonString);
      _cardRepo.getAll().forEach((card) {
        _cardRepo.remove(card);
      });
      restored.getAll().forEach((card) {
        _cardRepo.add(card);
      });
      await _cardRepo.save();
      notifyListeners();
    } catch (e, stackTrace) {
      SentryService.error(e, stackTrace);
      rethrow;
    }
  }

  /// For backup: get cards as JSON string
  String toJsonString() {
    return _cardRepo.toJson();
  }

  /// Get diff between current cards and another set
  CardRepositoryDiffResult getDiff(String otherJsonString) {
    CardRepository other = _cardRepo.encoder.decode(otherJsonString);
    return _cardRepo.getDiff(other);
  }

  /// Clear all cards from storage
  void clearCards() {
    _cardRepo.clearStorage();
    notifyListeners();
  }
}
