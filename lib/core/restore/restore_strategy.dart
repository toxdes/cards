import 'package:cards/repositories/card_repository.dart';

abstract class RestoreStrategy {
  final String key;
  final String label;
  final String desc;
  RestoreStrategy({required this.key, required this.label, required this.desc});
  Future<void> restore(CardRepository ours, CardRepository theirs);
}
