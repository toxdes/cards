import 'package:cards/core/db/sort.dart';
import 'package:cards/models/card/card.dart';

class SortByName extends Sort<CardModel> {
  @override
  int compare(CardModel a, CardModel b) {
    return a.getTitle().compareTo(b.getTitle());
  }

  @override
  String get label => "Name";
}

class SortByTimesUsed extends Sort<CardModel> {
  @override
  int compare(CardModel a, CardModel b) {
    return b.getUsedCount().compareTo(a.getUsedCount());
  }

  @override
  String get label => "Times Used";
}

class SortByDateAdded extends Sort<CardModel> {
  @override
  int compare(CardModel a, CardModel b) {
    return (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now());
  }

  @override
  String get label => "Date Added";
}

class NoSort extends Sort<CardModel> {
  @override
  int compare(CardModel a, CardModel b) {
    return 0;
  }

  @override
  String get label => "None";
}

Set<Sort<CardModel>> getAllSortStrategies() {
  Set<Sort<CardModel>> res = <Sort<CardModel>>{};
  res.add(SortByName());
  res.add(SortByTimesUsed());
  res.add(SortByDateAdded());
  return res;
}
