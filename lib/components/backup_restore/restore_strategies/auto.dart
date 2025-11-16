import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/repositories/card_repository.dart';

class AutoRestoreStrategy extends RestoreStrategy {
  AutoRestoreStrategy()
      : super(
            key: "auto",
            label: "Auto (Recommended)",
            desc:
                "Import new cards from the file, ignore deletions, pick most-recently updated card in case of conflict");

  @override
  Future<void> restore(CardRepository ours, CardRepository theirs) async {
    throw UnimplementedError();
  }
}
