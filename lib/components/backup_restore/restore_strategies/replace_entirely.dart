import 'dart:collection';

import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/cardlist/cardlist.dart';

class ReplaceEntirelyRestoreStrategy extends RestoreStrategy {
  ReplaceEntirelyRestoreStrategy()
      : super(
            key: "restore-entirely",
            label: "Replace entirely",
            desc:
                "Delete existing cards entirely, and add everything from the backup file. Not recommended unless you are sure you want this.");

  @override
  Future<void> restore(CardListModel ours, CardListModel theirs) async {
    UnmodifiableListView<CardModel> ourCards = ours.getAll();
    UnmodifiableListView<CardModel> theirCards = ours.getAll();
    for (int i = 0; i < ourCards.length; ++i) {
      ours.remove(ourCards[i]);
    }
    for (int i = 0; i < theirCards.length; ++i) {
      ours.add(theirCards[i]);
    }
    await ours.save();
  }
}
