import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/migrations/m_add_billing_cycle.dart';
import 'package:cards/models/card/migrations/migration_context.dart';
import 'package:test/test.dart';

void main() {
  test("add-billing-cycle migration", () async {
    CardMigrationContext context = CardMigrationContext();
    context.addMigration(AddBillingCycleMigration(id: 2));
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
              "schemaVersion":"1",
              "createdAt":"${source.getCreatedAt()}",
              "updatedAt":"${source.getUpdatedAt()}"
            }
      """);
    CardModel c2 = await context.runAllMigrations(c1);
    expect(c2.getBillingCycle(), null);
  });
}
