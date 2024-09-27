import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/migrations/m_add_timestamps.dart';
import 'package:cards/models/card/migrations/migration_context.dart';
import 'package:test/test.dart';

void main() {
  test("add-timestamp migration", () async {
    CardModel source = CardModelFactory.random();
    CardModel c1 = CardModelFactory.fromJson("""
{
 "title": "${source.getTitle()}",
  "number": "${source.getNumberView()}",
  "provider": "${source.getProviderView()}",
  "cvv": "${source.getCVV()}",
  "type": "${source.getCardTypeView()}",
  "expiry": "${source.getExpiry()}",
  "ownerName":"${source.getOwnerName()}"
  }
  """);
    CardMigrationContext context = CardMigrationContext();
    AddTimeStampsMigration addTimeStampsMigration =
        AddTimeStampsMigration(id: 1);
    context.addMigration(addTimeStampsMigration);
    expect(c1.getCreatedAt(), null);
    expect(c1.getUpdatedAt(), null);
    CardModel c2 = await context.runAllMigrations(c1);
    expect(c1.getCreatedAt(), null);
    expect(c1.getUpdatedAt(), null);
    expect(c2.getCreatedAt(), isNotNull);
    expect(c2.getUpdatedAt(), isNotNull);
    expect(c2.schemaVersion, 1);
  });
}
