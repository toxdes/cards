import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuItemWithSwitch extends StatelessWidget {
  const MenuItemWithSwitch(
      {super.key,
      required this.checked,
      required this.onChange,
      required this.title,
      this.icon,
      this.desc,
      this.iconColor = ThemeColors.white2,
      this.fgColor = ThemeColors.white2,
      this.bgColor = ThemeColors.gray1,
      this.borderColor = ThemeColors.gray3});

  final ValueSetter<bool> onChange;
  final bool checked;
  final String title;
  final String? desc;
  final IconData? icon;
  final Color fgColor, bgColor, borderColor, iconColor;

  @override
  Widget build(BuildContext context) {
    return MenuItemBase(
      bgColor: bgColor,
      borderColor: borderColor,
      onTap: () {
        onChange(!checked);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon != null
                  ? Icon(
                      icon,
                      color: iconColor,
                    )
                  : SizedBox.shrink(),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: fgColor,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          CupertinoSwitch(
              value: checked,
              activeTrackColor: ThemeColors.blue,
              inactiveTrackColor: ThemeColors.gray3,
              onChanged: (bool newValue) {
                onChange(newValue);
              }),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.onTap,
    required this.title,
    this.icon,
    this.desc,
    this.iconColor = ThemeColors.white2,
    this.fgColor = ThemeColors.white2,
    this.bgColor = ThemeColors.gray1,
    this.borderColor = ThemeColors.gray3,
  });
  final VoidCallback onTap;
  final String title;
  final String? desc;
  final IconData? icon;
  final Color fgColor, bgColor, iconColor, borderColor;
  @override
  Widget build(BuildContext context) {
    return MenuItemBase(
      onTap: onTap,
      borderColor: borderColor,
      bgColor: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon != null
                  ? Icon(icon, color: ThemeColors.white2)
                  : SizedBox.shrink(),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: ThemeColors.white2,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          Icon(
            Icons.chevron_right_outlined,
            color: ThemeColors.white2,
            size: 18,
          )
        ],
      ),
    );
  }
}

class MenuItemBase extends StatelessWidget {
  const MenuItemBase(
      {super.key,
      required this.child,
      this.onTap,
      required this.bgColor,
      required this.borderColor});
  final Widget child;
  final VoidCallback? onTap;
  final Color bgColor, borderColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          height: 64,
          decoration: BoxDecoration(
              color: bgColor,
              border: BoxBorder.fromLTRB(
                  bottom: BorderSide(color: ThemeColors.gray3, width: 1),
                  top: BorderSide(color: ThemeColors.gray3, width: 1))),
          width: double.infinity,
          child: child,
        ));
  }
}
