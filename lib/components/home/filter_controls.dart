import 'package:cards/components/shared/chip.dart';
import 'package:cards/core/db/filter.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/providers/card_filters.dart';
import 'package:cards/providers/cards_notifier.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:provider/provider.dart';

class FilterControls extends StatelessWidget {
  const FilterControls({super.key, required this.onTuneIconTap});
  final VoidCallback onTuneIconTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<CardsNotifier>(builder: (context, cardsNotifier, _) {
      Set<Filter<CardModel>> all = getAllFilters();
      EdgeInsets chipPadding = EdgeInsets.fromLTRB(12, 4, 12, 4);

      // TODO: currently these are hardcoded, plan is to have user created filter "shortcuts", which will replace these hardcoded ones.
      List<Widget> specialFilterChips = all.map((Filter<CardModel> f) {
        bool isActive = cardsNotifier.isFilterActive(f);
        return Container(
          margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Chip(
              checked: isActive,
              label: f.label,
              padding: chipPadding,
              onTap: () {
                if (isActive) {
                  cardsNotifier.removeFilter(f);
                } else {
                  cardsNotifier.addFilter(f);
                }
              }),
        );
      }).toList();

      return Padding(
          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...specialFilterChips,
              Chip(
                  checked: false,
                  icon: Icons.tune_rounded,
                  padding: chipPadding,
                  onTap: onTuneIconTap)
            ],
          ));
    });
  }
}
