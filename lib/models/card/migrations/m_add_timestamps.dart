import 'package:cards/core/db/migration.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';

class AddTimeStampsMigration extends Migration<CardModel> {
  AddTimeStampsMigration({required super.id})
      : super(fromSchemaId: 0, toSchemaId: 1);

  @override
  Future<CardModel> migrate(CardModel sourceModel) async {
    return CardModelFactory.copyFrom(sourceModel, toSchemaId)
      ..setCreatedAt(DateTime.now())
      ..setUpdatedAt(DateTime.now());
  }
}
