import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/textinput.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:cards/models/card/card_fields_formatter.dart';
import 'package:cards/models/card/card_fields_validator.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/material.dart' hide BottomSheet;
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

  final TextInputFormatter _cardNumberFormatter =
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.only(top: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextInputField(
              title: "Card number",
              helper: "All good!",
              hint: "XXXX XXXX XXXX XXXX",
              keyboardType: TextInputType.number,
              inputFormatters: [_cardNumberFormatter],
              validator: CardFieldsValidator.number,
              controller: _numberController,
              updateFormStatus: updateFormValidationStatus,
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
                    updateFormStatus: updateFormValidationStatus,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextInputField(
                    title: "CVV",
                    helper: "All good!",
                    hint: "XXX",
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
                    CardModel card = CardModelFactory.random()
                      ..setTitle(_titleController.text)
                      ..setNumber(
                          StringUtils.removeAll(_numberController.text, ' '))
                      ..setExpiry(_expiryController.text)
                      ..setOwnerName(_ownerNameController.text)
                      ..setCVV(_cvvController.text);
                    widget.onSubmit(card);
                  }
                },
                disabled: !_isFormValid,
                alignment: Alignment.center,
                height: 48,
                text: "Save card")
          ],
        ),
      ),
    );
  }
}
