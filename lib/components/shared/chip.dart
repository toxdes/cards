import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:flutter/material.dart';

class Chip extends StatelessWidget {
  final bool checked;
  final String? label;
  final bool disabled;
  final VoidCallback? onTap;
  final Color? bgColor;
  final Color? fgColor;
  final EdgeInsets? padding;
  final IconData? icon;
  const Chip(
      {super.key,
      required this.checked,
      this.label,
      this.disabled = false,
      this.onTap,
      this.bgColor = ThemeColors.white1,
      this.fgColor = ThemeColors.gray1,
      this.padding,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Button(
      label: label,
      icon: icon,
      disabled: disabled,
      padding: padding,
      buttonType: checked ? ButtonType.primary : ButtonType.outline,
      onTap: onTap ?? () {},
      color: checked ? bgColor! : fgColor!,
      labelColor: checked ? fgColor! : bgColor!,
    );
  }
}
