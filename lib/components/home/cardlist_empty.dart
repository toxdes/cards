import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/providers/cards_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardListEmpty extends StatelessWidget {
  final String noCardsLabel;
  final String noVisibleCardsLabel;
  const CardListEmpty(
      {super.key,
      this.noCardsLabel = "You haven't added any cards yet.",
      this.noVisibleCardsLabel = "No cards match the filters."});
  @override
  Widget build(BuildContext context) {
    return Consumer<CardsNotifier>(builder: (context, cardsNotifier, _) {
      return Container(
          margin: const EdgeInsets.fromLTRB(16, 48, 16, 32),
          child: Text(
              cardsNotifier.getCardsCount() == 0
                  ? noCardsLabel
                  : noVisibleCardsLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: Fonts.rubik,
                  fontWeight: FontWeight.w400,
                  color: ThemeColors.white2)));
    });
  }
}
