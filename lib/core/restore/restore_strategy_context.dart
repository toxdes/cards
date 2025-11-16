import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/repositories/card_repository.dart';

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

  void restore(CardRepository ours, CardRepository theirs) async {
    if (_strategy == null) {
      throw RestoreStrategyException(RestoreStrategyErrorCodes.noStrategy,
          "called restore() without setting a restore strategy first");
    }
    await _strategy!.restore(ours, theirs);
  }
}
