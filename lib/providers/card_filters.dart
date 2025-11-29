import 'package:cards/core/db/filter.dart';
import 'package:cards/models/card/card.dart';

class DebitCardFilter extends Filter<CardModel> {
  @override
  bool ok(CardModel t) {
    // TODO: get rid of name based filters once edit-card functionality is added
    return t.getTitle().toLowerCase().contains("debit");
  }

  @override
  String get label => "Debit";
}

class CreditCardFilter extends Filter<CardModel> {
  @override
  bool ok(CardModel t) {
    // TODO: get rid of name based filters once edit-card functionality is added
    return !t.getTitle().toLowerCase().contains("debit");
  }

  @override
  String get label => "Credit";
}

class RupayFilter extends Filter<CardModel> {
  @override
  bool ok(CardModel t) {
    return t.provider == CardProvider.rupay ||
        t.provider == CardProvider.discover;
  }

  @override
  String get label => "RuPay";
}

class VisaFilter extends Filter<CardModel> {
  @override
  bool ok(CardModel t) {
    return t.provider == CardProvider.visa;
  }

  @override
  String get label => "Visa";
}

class MasterCardFilter extends Filter<CardModel> {
  @override
  bool ok(CardModel t) {
    return t.provider == CardProvider.mastercard;
  }

  @override
  String get label => "MasterCard";
}

class AllFilter extends Filter<CardModel> {
  @override
  bool ok(CardModel _) {
    return true;
  }

  @override
  String get label => "All";
}

// ...more filters if needed
Set<Filter<CardModel>> getAllFilters() {
  Set<Filter<CardModel>> res = <Filter<CardModel>>{};
  res.add(CreditCardFilter());
  res.add(DebitCardFilter());
  return res;
}
