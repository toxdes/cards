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

  String _getProviderLabel() {
    switch (selectedProvider) {
      case CardProvider.visa:
        return "Visa";
      case CardProvider.mastercard:
        return "MasterCard";
      case CardProvider.amex:
        return "Amex";
      case CardProvider.discover:
        return "Discover";
      case CardProvider.rupay:
        return "RuPay";
      case CardProvider.unknown:
        return "Unknown";
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
                Text(
                  _getProviderLabel(),
                  style: const TextStyle(
                    fontFamily: Fonts.rubik,
                    fontSize: 16,
                    color: ThemeColors.white2,
                  ),
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
