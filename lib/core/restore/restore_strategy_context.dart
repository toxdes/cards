import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/models/cardlist/cardlist.dart';

class RestoreStrategyErrorCodes {
  static const noStrategy = 0x101;
}

class RestoreStrategyException implements Exception {
  final String message;
  final int errorCode;
  RestoreStrategyException(this.errorCode, this.message);
  @override
  String toString() {
    return '[RestoreStrategyException] Error $errorCode: $message';
  }
}

class RestoreStrategyContext {
  RestoreStrategy? _strategy;
  RestoreStrategyContext();

  void setRestoreStrategy(RestoreStrategy strategy) {
    _strategy = strategy;
  }

  RestoreStrategy? getRestoreStrategy() {
    return _strategy;
  }

  void restore(CardListModel ours, CardListModel theirs) async {
    if (_strategy == null) {
      throw RestoreStrategyException(RestoreStrategyErrorCodes.noStrategy,
          "called restore() without setting a restore strategy first");
    }
    await _strategy!.restore(ours, theirs);
  }
}
