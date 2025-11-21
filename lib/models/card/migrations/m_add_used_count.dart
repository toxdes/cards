import 'package:cards/core/db/migration.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';

class AddUsedCountMigration extends Migration<CardModel> {
  AddUsedCountMigration({required super.id})
      : super(fromSchemaId: 3, toSchemaId: 4);

  @override
  Future<CardModel> migrate(CardModel sourceModel) async {
    CardModel next = CardModelFactory.copyFrom(sourceModel, toSchemaId);
    next.usedCount = 0;
    return next;
  }
}
