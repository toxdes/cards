import 'dart:collection';

import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/repositories/card_repository.dart';

class ReplaceEntirelyRestoreStrategy extends RestoreStrategy {
  ReplaceEntirelyRestoreStrategy()
      : super(
            key: "restore-entirely",
            label: "Replace entirely",
            desc:
                "Delete existing cards entirely, and add everything from the backup file. Not recommended unless you are sure you want this.");

  @override
  Future<void> restore(CardRepository ours, CardRepository theirs) async {
    UnmodifiableListView<CardModel> theirCards = theirs.getAll();
    ours.removeAll();
    for (int i = 0; i < theirCards.length; ++i) {
      ours.add(theirCards[i]);
    }
    await ours.save();
  }
}
