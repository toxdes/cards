import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputField extends StatefulWidget {
  const TextInputField(
      {super.key,
      required this.title,
      required this.helper,
      required this.hint,
      required this.keyboardType,
      required this.validator,
      required this.updateFormStatus,
      this.inputFormatters,
      this.controller,
      this.textCapitalization,
      this.labelColor,
      this.color});

  final String title;
  final String helper;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final TextCapitalization? textCapitalization;
  final Color? labelColor;
  final Color? color;
  final void Function() updateFormStatus;
  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  static const _borderRadius = BorderRadius.all(Radius.circular(8));
  static const _contentPadding = EdgeInsets.all(16);
  InputDecoration _buildTextfieldDecoration(
          {String title = "", String helper = "", String hint = ""}) =>
      InputDecoration(
          helperText: helper,
          hintText: hint,
          filled: true,
          fillColor: ThemeColors.gray2,
          contentPadding: _contentPadding,
          errorStyle:
              const TextStyle(fontFamily: Fonts.rubik, color: ThemeColors.red),
          hintStyle: const TextStyle(
              color: ThemeColors.white3, fontFamily: Fonts.rubik),
          helperStyle: const TextStyle(
              fontFamily: Fonts.rubik, color: ThemeColors.green),
          floatingLabelStyle:
              const TextStyle(fontFamily: Fonts.rubik, color: ThemeColors.blue),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: _borderRadius,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: ThemeColors.gray2),
            borderRadius: _borderRadius,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: ThemeColors.blue),
            borderRadius: _borderRadius,
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: ThemeColors.red),
            borderRadius: _borderRadius,
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: ThemeColors.red),
            borderRadius: _borderRadius,
          ),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          floatingLabelBehavior: FloatingLabelBehavior.never);

  TextStyle _buildTextStyle(Color? color) => TextStyle(
        fontFamily: Fonts.rubik,
        color: color ?? ThemeColors.white2,
      );
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: Fonts.rubik,
                fontSize: 14,
                color: widget.labelColor ?? ThemeColors.white3)),
        const SizedBox(height: 8),
        TextFormField(
          validator: (String? value) {
            return widget.validator(value);
          },
          onChanged: (String? value) {
            widget.updateFormStatus();
          },
          selectionControls: null,
          style: _buildTextStyle(widget.color),
          autovalidateMode: AutovalidateMode.always,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          controller: widget.controller,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          decoration: _buildTextfieldDecoration(
              title: widget.title, helper: widget.helper, hint: widget.hint),
        ),
      ],
    );
  }
}
