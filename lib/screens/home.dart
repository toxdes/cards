import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CardModel> _cards = <CardModel>[];

  void addCard(CardModel c) {
    c.randomize();
    setState(() {
      _cards = [c, ..._cards];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
        decoration: const BoxDecoration(color: ThemeColors.gray1),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Saved cards (${_cards.length})",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontFamily: Fonts.rubik,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.white2)),
                const SizedBox(height: 12),
                Expanded(
                    child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: _cards.isEmpty
                      ? [
                          Container(
                              margin: const EdgeInsets.fromLTRB(16, 48, 16, 32),
                              child: const Text(
                                  "You haven't added any cards yet.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: Fonts.rubik,
                                      fontWeight: FontWeight.w400,
                                      color: ThemeColors.white2)))
                        ]
                      : _cards.map((CardModel card) {
                          return CardView(
                            card: card,
                          );
                        }).toList(),
                )),
                GestureDetector(
                    onTap: () {
                      addCard(CardModel(
                          CardType.credit,
                          CardProvider.visa,
                          "Card Name",
                          "1234 5678 9012 3456",
                          "403",
                          "01/28",
                          "Vaibhav"));
                    },
                    child: Stack(children: [
                      Container(
                          // width: 160,
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          margin: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: ThemeColors.blue,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text("Add new card",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ThemeColors.white1, fontSize: 16))),
                    ])),
              ],
            )));
  }
}

class CardView extends StatelessWidget {
  final CardModel card;
  CardView({required this.card}) : super(key: ObjectKey((card)));

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(4, 16, 4, 16),
        height: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: ThemeColors.gray2, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.cardName,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                  color: ThemeColors.teal,
                  fontFamily: Fonts.rubik,
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              card.number,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                  color: ThemeColors.white2,
                  fontFamily: Fonts.rubik,
                  fontWeight: FontWeight.w400,
                  fontSize: 24),
            ),
            const SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.expiry,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: ThemeColors.white2,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        fontSize: 16),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    card.cvv,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: ThemeColors.white2,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        fontSize: 16),
                  )
                ]),
            Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  Expanded(
                      child: Text(
                    card.ownerName.toUpperCase(),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: ThemeColors.white3,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 2,
                        fontSize: 14),
                  )),
                  Text(
                    card.provider == CardProvider.visa
                        ? "VISA"
                        : card.provider == CardProvider.rupay
                            ? "RuPay"
                            : "Mastercard",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: card.provider == CardProvider.visa
                            ? ThemeColors.yellow
                            : card.provider == CardProvider.rupay
                                ? ThemeColors.green
                                : ThemeColors.red,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                  )
                ]))
          ],
        ));
  }
}
