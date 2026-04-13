import 'package:cards/components/home/card_number_input.dart';
import 'package:cards/components/home/card_type_selector.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/textinput.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/card_fields_formatter.dart';
import 'package:cards/models/card/card_fields_validator.dart';
import 'package:cards/utils/card_utils.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNewCardForm extends StatefulWidget {
  const AddNewCardForm({super.key, required this.onSubmit});
  final ValueSetter<CardModel> onSubmit;
  @override
  State<AddNewCardForm> createState() => _AddNewCardFormState();
}

class _AddNewCardFormState extends State<AddNewCardForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _isCompleteCardNumber = true;
  CardProvider _selectedProvider = CardProvider.unknown;
  bool _isProviderManuallySelected = false;
  bool _isCardTypePickerVisible = false;

  final CardNumberFormatter _cardNumberFormatter =
      CardFieldsFormatter.numberFormatter();
  final TextInputFormatter _expiryFormatter =
      CardFieldsFormatter.expiryFormatter();
  final TextInputFormatter _cvvFormatter = CardFieldsFormatter.cvvFormatter();
  final TextInputFormatter _ownerNameFormatter =
      CardFieldsFormatter.ownerNameFormatter();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cardNumberFormatter.setIsCompleteCardNumber(_isCompleteCardNumber);
    CardFieldsValidator.setIsCompleteCardNumber(_isCompleteCardNumber);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  void updateFormValidationStatus() {
    bool res =
        _formKey.currentState != null && _formKey.currentState!.validate();

    if (res != _isFormValid) {
      setState(() {
        _isFormValid = res;
      });
    }
  }

  void _onCardNumberChanged(String _) {
    if (!_isProviderManuallySelected && _isCompleteCardNumber) {
      final cleanNumber = StringUtils.removeAll(_numberController.text, ' ');
      final detected = CardUtils.getProviderFromNumber(cleanNumber);
      if (detected != _selectedProvider) {
        setState(() {
          _selectedProvider = detected;
        });
      }
    }
  }

  void _resetProvider() {
    setState(() {
      _selectedProvider = CardProvider.unknown;
      _isProviderManuallySelected = false;
    });
  }

  void _toggleCardTypePicker(bool? visibility) {
    if (visibility == true || (visibility == null && !_isCardTypePickerVisible)) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: ThemeColors.gray1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Card Type",
                        style: const TextStyle(
                          fontFamily: Fonts.rubik,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.white2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: const Icon(
                          Icons.close,
                          color: ThemeColors.white3,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildCardTypeOption(dialogContext, "Visa", CardProvider.visa, Icons.credit_card),
                        _buildCardTypeOption(dialogContext, "MasterCard", CardProvider.mastercard, Icons.credit_card),
                        _buildCardTypeOption(dialogContext, "Amex", CardProvider.amex, Icons.credit_card),
                        _buildCardTypeOption(dialogContext, "Discover", CardProvider.discover, Icons.credit_card),
                        _buildCardTypeOption(dialogContext, "RuPay", CardProvider.rupay, Icons.credit_card),
                        _buildCardTypeOption(dialogContext, "Unknown", CardProvider.unknown, Icons.help_outline),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((_) {
        setState(() {
          _isCardTypePickerVisible = false;
        });
      });
      setState(() {
        _isCardTypePickerVisible = true;
      });
    } else {
      setState(() {
        _isCardTypePickerVisible = false;
      });
    }
  }

  void onToggleCompleteCardNumber() {
    CardFieldsValidator.setIsCompleteCardNumber(!_isCompleteCardNumber);
    _cardNumberFormatter.setIsCompleteCardNumber(!_isCompleteCardNumber);
    _numberController.text = "";
    _resetProvider();
    setState(() {
      _isCompleteCardNumber = !_isCompleteCardNumber;
    });
  }

  Widget _buildCardTypeOption(BuildContext dialogContext, String label, CardProvider provider, IconData icon) {
    final isSelected = _selectedProvider == provider;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProvider = provider;
          _isProviderManuallySelected = true;
        });
        Navigator.of(dialogContext).pop();
      },
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
            Icon(
              icon,
              color: isSelected ? ThemeColors.blue : ThemeColors.white3,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: Fonts.rubik,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? ThemeColors.blue : ThemeColors.white2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets padding = EdgeInsets.all(16);
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.only(top: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CardNumberInput(
              title: "Card number",
              helper: "All good!",
              hint: "XXXX XXXX XXXX XXXX",
              keyboardType: TextInputType.number,
              inputFormatters: [_cardNumberFormatter],
              validator: CardFieldsValidator.number,
              controller: _numberController,
              updateFormStatus: updateFormValidationStatus,
              isCompleteCardNumber: _isCompleteCardNumber,
              onToggleCompleteCardNumber: onToggleCompleteCardNumber,
              onCardNumberChanged: () => _onCardNumberChanged(_numberController.text),
            ),
            const SizedBox(height: 8),
            CardTypeSelector(
              title: "Card type",
              selectedProvider: _selectedProvider,
              onTap: () => _toggleCardTypePicker(true),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextInputField(
                    title: "Expiry",
                    helper: "All good!",
                    hint: "MM/YY",
                    keyboardType: TextInputType.number,
                    inputFormatters: [_expiryFormatter],
                    validator: CardFieldsValidator.expiry,
                    controller: _expiryController,
                    contentPadding: padding,
                    updateFormStatus: updateFormValidationStatus,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextInputField(
                    title: "CVV(Optional)",
                    helper: _cvvController.text.isNotEmpty ? "All good!" : "",
                    hint: "XXX",
                    contentPadding: padding,
                    validator: CardFieldsValidator.cvv,
                    inputFormatters: [_cvvFormatter],
                    keyboardType: TextInputType.number,
                    controller: _cvvController,
                    updateFormStatus: updateFormValidationStatus,
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            TextInputField(
              title: "Owner Name",
              helper: "All good!",
              hint: "Card holder name",
              validator: CardFieldsValidator.ownerName,
              keyboardType: TextInputType.name,
              controller: _ownerNameController,
              inputFormatters: [_ownerNameFormatter],
              textCapitalization: TextCapitalization.characters,
              updateFormStatus: updateFormValidationStatus,
            ),
            const SizedBox(height: 8),
            TextInputField(
              title: "Save card as",
              helper: "All good!",
              hint: "e.g. Amazon Pay ICICI card",
              keyboardType: TextInputType.name,
              validator: CardFieldsValidator.title,
              controller: _titleController,
              labelColor: ThemeColors.teal,
              color: ThemeColors.teal,
              updateFormStatus: updateFormValidationStatus,
            ),
            const SizedBox(height: 16),
            Button(
                color: ThemeColors.blue,
                onTap: () {
                  if (_isFormValid) {
                    CardModel card = CardModelFactory.blank()
                      ..setTitle(_titleController.text)
                      ..setNumber(
                          StringUtils.removeAll(_numberController.text, ' '))
                      ..setExpiry(_expiryController.text)
                      ..setOwnerName(_ownerNameController.text)
                      ..setProvider(_selectedProvider)
                      ..setCVV(_cvvController.text)
                      ..setCardNumberType(_isCompleteCardNumber
                          ? CardNumberType.complete
                          : CardNumberType.last4);
                    widget.onSubmit(card);
                  }
                },
                disabled: !_isFormValid,
                alignment: Alignment.center,
                height: 48,
                label: "Save card"),
          ],
        ),
      ),
    );
  }
}
