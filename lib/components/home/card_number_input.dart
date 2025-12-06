import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/textinput.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardNumberInput extends StatelessWidget {
  final String title, helper, hint;

  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?) validator;
  final TextEditingController controller;
  final VoidCallback updateFormStatus;
  final VoidCallback onToggleCompleteCardNumber;
  final bool isCompleteCardNumber;
  const CardNumberInput(
      {super.key,
      required this.title,
      required this.helper,
      required this.hint,
      required this.keyboardType,
      required this.inputFormatters,
      required this.validator,
      required this.controller,
      required this.updateFormStatus,
      required this.onToggleCompleteCardNumber,
      required this.isCompleteCardNumber});

  Widget get prefix => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin:
                  EdgeInsets.fromLTRB(16, 0, isCompleteCardNumber ? 8 : 4, 0),
              child: Button(
                  label: isCompleteCardNumber ? "Complete" : "Last 4",
                  color: ThemeColors.blue,
                  buttonType: ButtonType.primary,
                  labelColor: ThemeColors.white1,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  onTap: onToggleCompleteCardNumber),
            ),
            !isCompleteCardNumber
                ? Container(
                    color: ThemeColors.gray2,
                    margin: EdgeInsets.fromLTRB(4, 0, 2, 0),
                    child: Text("XXXX XXXX XXXX",
                        style: TextStyle(
                          color: ThemeColors.teal,
                          fontFamily: Fonts.rubik,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        )))
                : SizedBox.shrink(),
          ]);

  @override
  Widget build(BuildContext context) {
    return TextInputField(
        title: "Card number",
        helper: "All good!",
        hint: isCompleteCardNumber ? "XXXX XXXX XXXX XXXX" : "XXXX",
        keyboardType: TextInputType.number,
        inputFormatters: inputFormatters,
        validator: validator,
        prefix: prefix,
        controller: controller,
        updateFormStatus: updateFormStatus);
  }
}
