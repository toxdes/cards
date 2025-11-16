import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/repositories/card_repository.dart';

class DoNothingRestoreStrategy extends RestoreStrategy {
  DoNothingRestoreStrategy()
      : super(
            key: "do-nothing",
            label: "Do nothing",
            desc: "Don't do anything. Exit.");

  @override
  Future<void> restore(CardRepository ours, CardRepository theirs) async {}
}
