import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card.dart';
import 'package:flutter/material.dart';

class CardView extends StatefulWidget {
  final CardModel card;
  CardView({required this.card}) : super(key: ObjectKey((card)));

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
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
              widget.card.cardName,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                  color: ThemeColors.teal,
                  fontFamily: Fonts.rubik,
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              widget.card.number,
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
                    widget.card.expiry,
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
                    widget.card.cvv,
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
                    widget.card.ownerName.toUpperCase(),
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
                    widget.card.provider == CardProvider.visa
                        ? "VISA"
                        : widget.card.provider == CardProvider.rupay
                            ? "RuPay"
                            : "Mastercard",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: widget.card.provider == CardProvider.visa
                            ? ThemeColors.yellow
                            : widget.card.provider == CardProvider.rupay
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
