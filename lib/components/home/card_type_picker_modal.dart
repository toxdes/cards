import 'package:cards/components/shared/bottom_sheet.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/models/card/card.dart';
import 'package:flutter/material.dart' hide BottomSheet;

class CardTypePickerModal extends StatelessWidget {
  final String title;
  final String closeLabel;
  final VoidCallback onClose;
  final bool isVisible;
  final CardProvider currentProvider;
  final Function(CardProvider) onProviderSelected;

  const CardTypePickerModal({
    super.key,
    required this.title,
    required this.closeLabel,
    required this.onClose,
    required this.isVisible,
    required this.currentProvider,
    required this.onProviderSelected,
  });

  String _getCardTypeImage(CardProvider provider) {
    switch (provider) {
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

  Widget _buildCardTypeOption(CardProvider provider) {
    final isSelected = currentProvider == provider;
    return GestureDetector(
      onTap: () => onProviderSelected(provider),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.blue.withValues(alpha: 0.2)
              : ThemeColors.gray2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ThemeColors.blue : ThemeColors.gray3,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              _getCardTypeImage(provider),
              width: 60,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.credit_card,
                  color: isSelected ? ThemeColors.blue : ThemeColors.white3,
                  size: 40,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      title: title,
      closeLabel: closeLabel,
      onClose: onClose,
      isVisible: isVisible,
      maxHeightFactor: 0.4,
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        children: [
          _buildCardTypeOption(CardProvider.visa),
          _buildCardTypeOption(CardProvider.mastercard),
          _buildCardTypeOption(CardProvider.amex),
          _buildCardTypeOption(CardProvider.discover),
          _buildCardTypeOption(CardProvider.rupay),
          _buildCardTypeOption(CardProvider.unknown),
        ],
      ),
    );
  }
}
