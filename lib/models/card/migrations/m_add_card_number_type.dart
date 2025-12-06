import 'package:cards/core/db/migration.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';

class AddCardNumberTypeMigration extends Migration<CardModel> {
  AddCardNumberTypeMigration({required super.id})
      : super(fromSchemaId: 4, toSchemaId: 5);

  @override
  Future<CardModel> migrate(CardModel sourceModel) async {
    CardModel next = CardModelFactory.copyFrom(sourceModel, toSchemaId);
    next.setCardNumberType(CardNumberType.complete);
    return next;
  }
}
