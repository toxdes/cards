import 'package:cards/core/db/migration.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';

class AddTimeStampsMigration extends Migration<CardModel> {
  AddTimeStampsMigration({required super.id})
      : super(fromSchemaId: 0, toSchemaId: 1);

  @override
  Future<CardModel> migrate(CardModel sourceModel) async {
    CardModel next = CardModelFactory.copyFrom(sourceModel, toSchemaId);
    if (next.createdAt == null) {
      next.setCreatedAt(DateTime.now());
    }
    if (next.updatedAt == null) {
      next.setUpdatedAt(DateTime.now());
    }
    return next;
  }
}
