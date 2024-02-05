import 'dart:math';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/textinput.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/card/card_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNewCardForm extends StatefulWidget {
  const AddNewCardForm({super.key, required this.onSubmit});
  final ValueSetter<CardModel> onSubmit;
  @override
  State<AddNewCardForm> createState() => _AddNewCardFormState();
}

class FieldsValidator {
  static String? title(String? maybeTitle) {
    if (maybeTitle == null || maybeTitle.isEmpty) {
      return "title shouldn't be empty";
    }
    return null;
  }

  static bool isWhitespace(String s) {
    return s == ' ' || s == '\t' || s == '\n';
  }

  static bool isDigit(String s) {
    int? res = int.tryParse(s);
    return s.length == 1 && res != null && res >= 0 && res <= 9;
  }

  static bool _isOnlyDigits(String input, {bool ignoreWhitespace = true}) {
    bool hasOnlyDigits = true;
    for (int i = 0; i < input.length; ++i) {
      if (ignoreWhitespace && isWhitespace(input[i])) continue;
      if (!isDigit(input[i])) {
        hasOnlyDigits = false;
        break;
      }
    }
    return hasOnlyDigits;
  }

  static String removeAll(String input, String pat) {
    return input.replaceAll(pat, '');
  }

  static String? number(String? maybeNumber) {
    if (maybeNumber == null || maybeNumber.isEmpty) {
      return "number shouldn't be empty";
    }
    if (!_isOnlyDigits(maybeNumber)) {
      return "number should only contain digits";
    }
    if (removeAll(maybeNumber, ' ').length != 16) {
      return "number should be exactly 16 digits";
    }
    return null;
  }

  static String? expiry(String? maybeExpiry) {
    if (maybeExpiry == null || maybeExpiry.isEmpty) {
      return "shouldn't be empty";
    }
    String processedExpiry = removeAll(removeAll(maybeExpiry, ' '), '/');
    if (processedExpiry.length != 4) {
      return "should match MM/YY";
    }
    int? month = int.tryParse("${processedExpiry[0]}${processedExpiry[1]}");
    if (month == null || month < 1 || month > 12) {
      return "invalid month(MM)";
    }
    int? year = int.tryParse("${processedExpiry[2]}${processedExpiry[3]}");
    if (year == null) {
      return "invalid year(YY)";
    }
    return null;
  }

  static String? cvv(String? maybeCvv) {
    if (maybeCvv == null || maybeCvv.isEmpty) {
      return "shouldn't be empty";
    }
    String processedCvv = removeAll(maybeCvv, ' ');
    if (processedCvv.length != 3) {
      return "should be 3 digits";
    }
    for (int i = 0; i < processedCvv.length; ++i) {
      if (!isDigit(processedCvv[i])) {
        return "only digits allowed";
      }
    }
    return null;
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String textWithoutWhitespace =
        FieldsValidator.removeAll(newValue.text.toString(), ' ');

    StringBuffer buf = StringBuffer();
    for (int i = 1; i <= min<int>(textWithoutWhitespace.length, 16); ++i) {
      if (FieldsValidator.isDigit(textWithoutWhitespace[i - 1])) {
        buf.write(textWithoutWhitespace[i - 1]);
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String textWithoutWhitespace =
        FieldsValidator.removeAll(newValue.text.toString(), ' ');
    String textWithoutSlash =
        FieldsValidator.removeAll(textWithoutWhitespace, '/');
    StringBuffer buf = StringBuffer();
    for (int i = 1; i <= min<int>(textWithoutSlash.length, 4); ++i) {
      if (FieldsValidator.isDigit(textWithoutSlash[i - 1])) {
        buf.write(textWithoutSlash[i - 1]);
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class CvvFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String textWithoutWhitespace =
        FieldsValidator.removeAll(newValue.text.toString(), ' ');
    StringBuffer buf = StringBuffer();
    for (int i = 1; i <= min<int>(textWithoutWhitespace.length, 3); ++i) {
      if (FieldsValidator.isDigit(textWithoutWhitespace[i - 1])) {
        buf.write(textWithoutWhitespace[i - 1]);
      }
    }
    String modifiedText = buf.toString();
    return newValue.copyWith(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}

class _AddNewCardFormState extends State<AddNewCardForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  final CardNumberFormatter _cardNumberFormatter = CardNumberFormatter();
  final ExpiryFormatter _expiryFormatter = ExpiryFormatter();
  final CvvFormatter _cvvFormatter = CvvFormatter();

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
        child: Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextInputField(
                    title: "Title",
                    helper: "All good!",
                    hint: "e.g. Amazon Pay ICICI card",
                    keyboardType: TextInputType.name,
                    validator: FieldsValidator.title,
                    controller: _titleController,
                    updateFormStatus: updateFormValidationStatus,
                  ),
                  const SizedBox(height: 16),
                  TextInputField(
                    title: "Card number",
                    helper: "All good!",
                    hint: "XXXX XXXX XXXX XXXX",
                    keyboardType: TextInputType.number,
                    inputFormatters: [_cardNumberFormatter],
                    validator: FieldsValidator.number,
                    controller: _numberController,
                    updateFormStatus: updateFormValidationStatus,
                  ),
                  const SizedBox(height: 16),
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
                          validator: FieldsValidator.expiry,
                          controller: _expiryController,
                          updateFormStatus: updateFormValidationStatus,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextInputField(
                          title: "CVV",
                          helper: "All good!",
                          hint: "XXX",
                          validator: FieldsValidator.cvv,
                          inputFormatters: [_cvvFormatter],
                          keyboardType: TextInputType.number,
                          controller: _cvvController,
                          updateFormStatus: updateFormValidationStatus,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Button(
                      onTap: () {
                        if (_isFormValid) {
                          CardModel card = CardModelFactory.random()
                            ..setTitle(_titleController.text)
                            ..setNumber(_numberController.text)
                            ..setExpiry(_expiryController.text)
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
          ),
        ));
  }
}
