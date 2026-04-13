import 'package:cards/components/shared/select_from_options.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/utils/card_utils.dart';
import 'package:cards/components/shared/bottom_sheet.dart';
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

  SelectOption? _findSelectedOption() {
    final providerKey = CardUtils.cardProviderToKey(currentProvider);
    final options = CardUtils.getCardProviderOptions();

    for (final option in options) {
      if (option.key == providerKey) {
        return option;
      }
    }
    return null;
  }

  void _handleOptionSelection(SelectOption selectedOption) {
    final provider = CardUtils.keyToCardProvider(selectedOption.key);
    onProviderSelected(provider);
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _findSelectedOption();

    return BottomSheet(
      title: title,
      closeLabel: closeLabel,
      onClose: onClose,
      isVisible: isVisible,
      maxHeightFactor: 0.6,
      child: SelectFromOptions(
        options: CardUtils.getCardProviderOptions(),
        selectedOption: selectedOption,
        onSelectOption: _handleOptionSelection,
        vertical: true,
      ),
    );
  }
}
