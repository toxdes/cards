import 'package:cards/models/cardlist/cardlist.dart';

abstract class RestoreStrategy {
  final String key;
  final String label;
  final String desc;
  RestoreStrategy({required this.key, required this.label, required this.desc});
  Future<void> restore(CardListModel ours, CardListModel theirs);
}
