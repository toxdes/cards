import 'package:cards/core/db/migration.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';

class AddBillingCycleMigration extends Migration<CardModel> {
  AddBillingCycleMigration({required super.id})
      : super(fromSchemaId: 1, toSchemaId: 2);

  @override
  Future<CardModel> migrate(CardModel sourceModel) async {
    return CardModelFactory.copyFrom(sourceModel, toSchemaId);
  }
}
