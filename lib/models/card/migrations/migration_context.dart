import 'package:cards/core/db/migration.dart';
import 'package:cards/core/db/migration_context.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';

class CardMigrationContext extends MigrationContext<CardModel> {
  @override
  Future<CardModel> runAllMigrations(CardModel sourceModel) async {
    CardModel nextModel =
        CardModelFactory.copyFrom(sourceModel, sourceModel.schemaVersion);
    for (int i = 0; i < migrations.length; ++i) {
      if (nextModel.schemaVersion != migrations[i].fromSchemaId &&
          nextModel.schemaVersion != 0) {
        continue;
      }
      nextModel = await migrations[i].migrate(nextModel);
    }
    return nextModel;
  }

  @override
  Future<void> addMigration(Migration<CardModel> migration) async {
    for (int i = 0; i < migrations.length; ++i) {
      if (migrations[i].id == migration.id) {
        return;
      }
    }
    migrations.add(migration);
  }
}
