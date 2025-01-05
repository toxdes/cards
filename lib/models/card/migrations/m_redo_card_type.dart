import 'package:cards/core/db/migration.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/utils/card_utils.dart';

class RedoCardTypeMigration extends Migration<CardModel> {
  RedoCardTypeMigration({required super.id})
      : super(fromSchemaId: 2, toSchemaId: 3);
  @override
  Future<CardModel> migrate(CardModel sourceModel) async {
    CardModel next = CardModelFactory.copyFrom(sourceModel, toSchemaId);
    next.setProvider(CardUtils.getProviderFromNumber(next.getNumber()));
    return next;
  }
}
