import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/migrations/m_add_billing_cycle.dart';
import 'package:cards/models/card/migrations/m_add_timestamps.dart';
import 'package:cards/models/card/migrations/m_redo_card_type.dart';
import 'package:cards/models/card/migrations/migration_context.dart';
import 'package:test/test.dart';

void main() {
  test(
      "combined add-ts, add-billing-cycle, redo-card-type migrations, in that order",
      () async {
    CardModel source = CardModelFactory.random();
    CardModel c1 = CardModelFactory.fromJson("""
        {
          "title": "${source.getTitle()}",
          "number": "6522 2334 2343 3321",
          "provider": "${source.getProviderView()}",
          "cvv": "${source.getCVV()}",
          "type": "${source.getCardTypeView()}",
          "expiry": "${source.getExpiry()}",
          "ownerName":"${source.getOwnerName()}"
        }
        """);
    CardMigrationContext context = CardMigrationContext();
    context.addMigration(AddTimeStampsMigration(id: 1));
    context.addMigration(AddBillingCycleMigration(id: 2));
    context.addMigration(RedoCardTypeMigration(id: 3));
    CardModel c2 = await context.runAllMigrations(c1);
    expect(c2.billingCycle, null);
    expect(c2.schemaVersion, 3);
    expect(c2.createdAt, isNotNull);
    expect(c2.updatedAt, isNotNull);
    expect(c2.getProvider(), CardProvider.rupay);
  });

  test("skips add-ts if add-ts was already applied before", () async {
    CardModel source = CardModelFactory.random();
    CardModel c1 = CardModelFactory.fromJson("""
        {
          "title": "${source.getTitle()}",
          "number": "${source.getNumberView()}",
          "provider": "${source.getProviderView()}",
          "cvv": "${source.getCVV()}",
          "type": "${source.getCardTypeView()}",
          "expiry": "${source.getExpiry()}",
          "ownerName":"${source.getOwnerName()}",
          "createdAt":"${source.getCreatedAt()}",
          "updatedAt":"${source.getUpdatedAt()}",
          "schemaVersion":"1"
        }
        """);
    CardMigrationContext context = CardMigrationContext();
    context.addMigration(AddTimeStampsMigration(id: 1));
    context.addMigration(AddBillingCycleMigration(id: 2));
    CardModel c2 = await context.runAllMigrations(c1);
    expect(c2.getCreatedAt(), equals(c1.getCreatedAt()));
    expect(c2.getUpdatedAt(), equals(c1.getUpdatedAt()));
    expect(c2.schemaVersion, 2);
  });
}
