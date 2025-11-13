import 'dart:collection';

import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/migrations/m_add_billing_cycle.dart';
import 'package:cards/models/card/migrations/m_add_timestamps.dart';
import 'package:cards/models/card/migrations/m_redo_card_type.dart';
import 'package:cards/models/card/migrations/migration_context.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:cards/services/toast_service.dart';
import 'package:cards/utils/secure_storage.dart';

class MigrationsService {
  static Future<void> runMigrations() async {
    await _runCardMigrations();
  }

  static Future<void> _runCardMigrations() async {
    CardMigrationContext context = CardMigrationContext();
    context.addMigration(AddTimeStampsMigration(id: 1));
    context.addMigration(AddBillingCycleMigration(id: 2));
    context.addMigration(RedoCardTypeMigration(id: 3));
    CardListModel cardListModel = CardListModel.the();
    await cardListModel.readFromStorage();
    UnmodifiableListView<CardModel> cards = cardListModel.getAll();
    if (cards.isEmpty) return;
    if (CardModelFactory.blank().schemaVersion != cards[0].schemaVersion) {
      ToastService.show(message: "Updating DB...", status: ToastStatus.info);
      List<CardModel> newCards = <CardModel>[];
      for (int i = 0; i < cards.length; ++i) {
        newCards.add(await context
            .runAllMigrations(CardModelFactory.fromJson(cards[i].toJson())));
      }
      CardListModel newCardListModel = CardListModel(
          storage: const SecureStorage(),
          storageKey: CardListModelStorageKeys.mainStorage);
      for (int i = 0; i < newCards.length; ++i) {
        newCardListModel.add(newCards[i]);
      }
      CardListModel.setThe(newCardListModel);
      await CardListModel.the().save();
      ToastService.show(message: "DB updated", status: ToastStatus.success);
    }
  }
}
