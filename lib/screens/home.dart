import 'package:cards/components/home/bottom_sheet.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/cardview.dart';
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
  bool _addNewCardFormVisible = false;

  void addCard(CardModel c) {
    setState(() {
      _cards = [..._cards, c];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          decoration: const BoxDecoration(color: ThemeColors.gray1),
          child: Stack(textDirection: TextDirection.ltr, children: [
            Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Saved cards (${_cards.length})",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontFamily: Fonts.rubik,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeColors.white2)),
                              Button(
                                text: "Add +",
                                buttonType: ButtonType.primary,
                                onTap: () {
                                  setState(() {
                                    _addNewCardFormVisible = true;
                                  });
                                },
                              ),
                            ]),
                        const SizedBox(height: 12),
                        Expanded(
                            child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: _cards.isEmpty
                              ? [
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          16, 48, 16, 32),
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
                      ],
                    ))),
            AddNewCardModal(
                isVisible: _addNewCardFormVisible,
                onClose: () {
                  setState(() {
                    _addNewCardFormVisible = false;
                  });
                },
                onAddNewCard: addCard),
          ])),
    );
  }
}
