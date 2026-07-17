import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card/card.dart';
import 'package:flutter/material.dart';

class CardTypeSelector extends StatelessWidget {
  final String title;
  final CardProvider selectedProvider;
  final VoidCallback onTap;

  const CardTypeSelector({
    super.key,
    required this.title,
    required this.selectedProvider,
    required this.onTap,
  });

  String _getCardTypeImage() {
    switch (selectedProvider) {
      case CardProvider.visa:
        return 'assets/card_types/visa.png';
      case CardProvider.mastercard:
        return 'assets/card_types/mastercard.png';
      case CardProvider.amex:
        return 'assets/card_types/amex.png';
      case CardProvider.discover:
        return 'assets/card_types/discover.png';
      case CardProvider.rupay:
        return 'assets/card_types/rupay.png';
      case CardProvider.unknown:
        return 'assets/card_types/unknown.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8));
    const EdgeInsets padding = EdgeInsets.all(16);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontFamily: Fonts.rubik,
            fontSize: 14,
            color: ThemeColors.white3,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: ThemeColors.gray2,
              borderRadius: borderRadius,
              border: Border.all(
                width: 1,
                color: ThemeColors.white3,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  _getCardTypeImage(),
                  width: 60,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.credit_card,
                      color: ThemeColors.white2,
                      size: 32,
                    );
                  },
                ),
                Icon(
                  Icons.expand_more,
                  color: ThemeColors.white3,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
