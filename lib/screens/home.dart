import 'package:cards/components/home/bottom_sheet.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/cardview.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CardListModel _cards = CardListModel();
  bool _addNewCardFormVisible = false;
  void addCard(CardModel c) {
    setState(() {
      _cards.add(c, sync: true);
      // _addNewCardFormVisible = false;
    });
  }

  void removeCard(CardModel c) {
    setState(() {
      _cards.remove(c, sync: true);
    });
  }

  @override
  void initState() {
    // _cards.clearStorage();
    _read();
    super.initState();
  }

  void _read() async {
    CardListModel existingCards = await CardListModel().readFromStorage();
    if (existingCards.length != 0) {
      setState(() {
        _cards = existingCards;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
            decoration: const BoxDecoration(color: ThemeColors.gray1),
            constraints: const BoxConstraints(maxWidth: 800),
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
                              ]),
                          const SizedBox(height: 12),
                          Expanded(
                              child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: _cards.length == 0
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
                                : _cards.getAll().map((CardModel card) {
                                    return CardView(
                                        card: card,
                                        onLongPress: (CardModel c) {
                                          removeCard(c);
                                        });
                                  }).toList(),
                          )),
                          Button(
                            text: "Add new card +",
                            buttonType: ButtonType.primary,
                            alignment: Alignment.center,
                            height: 48,
                            onTap: () {
                              setState(() {
                                _addNewCardFormVisible = true;
                              });
                            },
                          )
                              .animate(
                                  autoPlay: true,
                                  onComplete: (controller) {
                                    controller.loop(count: 3);
                                  })
                              .then(delay: 10.seconds)
                              .shake(
                                duration: 600.ms,
                                rotation: 0.02,
                              ),
                        ],
                      ))),
              AddNewCardModal(
                isVisible: _addNewCardFormVisible,
                onClose: () {
                  setState(() {
                    _addNewCardFormVisible = false;
                  });
                },
                onAddNewCard: addCard,
              ),
            ])),
      ),
    );
  }
}
