import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:flutter/material.dart';

class CardListDiffSummary extends StatelessWidget {
  final CardListModelDiffResult result;
  const CardListDiffSummary({super.key, required this.result});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        children: [
          Row(children: [
            Text(
              result.added.toString(),
              style: const TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: ThemeColors.green),
            ),
            const Text(
              " new cards",
              style: TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                  color: ThemeColors.green),
            ),
          ]),
          Row(children: [
            Text(
              result.removed.toString(),
              style: const TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: ThemeColors.red),
            ),
            const Text(
              " deleted cards",
              style: TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                  color: ThemeColors.red),
            ),
          ]),
          Row(children: [
            Text(
              result.changed.toString(),
              style: const TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: ThemeColors.yellow),
            ),
            const Text(
              " changed cards",
              style: TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                  color: ThemeColors.yellow),
            ),
          ]),
        ],
      ),
    );
  }
}
