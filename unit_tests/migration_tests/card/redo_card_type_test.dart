import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/migrations/m_redo_card_type.dart';
import 'package:cards/models/card/migrations/migration_context.dart';
import 'package:test/test.dart';

void main() {
  test("redo-card-type migration: discover -> rupay", () async {
    CardMigrationContext context = CardMigrationContext();
    context.addMigration(RedoCardTypeMigration(id: 3));
    CardModel c = CardModelFactory.random()..setProvider(CardProvider.discover);
    CardModel c1 = CardModelFactory.fromJson("""
            {
              "title": "test card",
              "number": "6522 0401 2293 1202",
              "provider": "${c.getProviderView()}",
              "cvv": "${c.getCVV()}",
              "type": "${c.getCardTypeView()}",
              "expiry": "${c.getExpiry()}",
              "ownerName":"${c.getOwnerName()}",
              "schemaVersion":"2",
              "createdAt":"${c.getCreatedAt()}",
              "updatedAt":"${c.getUpdatedAt()}"
            }
      """);
    CardModel c2 = await context.runAllMigrations(c1);
    expect(c1.getProvider(), CardProvider.discover);
    expect(c2.getProvider(), CardProvider.rupay);
  });

  test("redo-card-type migration: unknown -> rupay", () async {
    CardMigrationContext context = CardMigrationContext();
    context.addMigration(RedoCardTypeMigration(id: 3));
    CardModel c = CardModelFactory.random()..setProvider(CardProvider.unknown);
    CardModel c1 = CardModelFactory.fromJson("""
            {
              "title": "test card",
              "number": "8177 0401 2293 1202",
              "provider": "${c.getProviderView()}",
              "cvv": "${c.getCVV()}",
              "type": "${c.getCardTypeView()}",
              "expiry": "${c.getExpiry()}",
              "ownerName":"${c.getOwnerName()}",
              "schemaVersion":"2",
              "createdAt":"${c.getCreatedAt()}",
              "updatedAt":"${c.getUpdatedAt()}"
            }
      """);
    CardModel c2 = await context.runAllMigrations(c1);
    expect(c1.getProvider(), CardProvider.unknown);
    expect(c2.getProvider(), CardProvider.rupay);
  });
}
