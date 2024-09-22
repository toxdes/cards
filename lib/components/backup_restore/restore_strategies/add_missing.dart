import 'dart:collection';

import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/cardlist/cardlist.dart';

class AddMissingRestoreStrategy extends RestoreStrategy {
  AddMissingRestoreStrategy()
      : super(
            key: "add-missing",
            label: "Add missing",
            desc:
                "Import new cards from the file, ignore deletions, ignore conflicts");

  @override
  Future<void> restore(CardListModel ours, CardListModel theirs) async {
    HashSet<String> existing = HashSet<String>();
    UnmodifiableListView<CardModel> ourCards = ours.getAll();
    UnmodifiableListView<CardModel> theirCards = theirs.getAll();
    for (int i = 0; i < ourCards.length; ++i) {
      existing.add(ourCards[i].getNumber());
    }
    for (int i = 0; i < theirCards.length; ++i) {
      if (!existing.contains(theirCards[i].getNumber())) {
        ours.add(theirCards[i]);
      }
    }
    await ours.save();
  }
}
