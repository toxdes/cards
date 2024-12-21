import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/models/cardlist/cardlist.dart';

class DoNothingRestoreStrategy extends RestoreStrategy {
  DoNothingRestoreStrategy()
      : super(
            key: "do-nothing",
            label: "Do nothing",
            desc: "Don't do anything. Exit.");

  @override
  Future<void> restore(CardListModel ours, CardListModel theirs) async {}
}
