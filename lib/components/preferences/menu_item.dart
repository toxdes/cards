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
      this.borderColor = ThemeColors.gray3,
      this.descColor = ThemeColors.white3,
      this.disabled = false});

  final ValueSetter<bool> onChange;
  final bool checked;
  final String title;
  final String? desc;
  final IconData? icon;
  final bool disabled;
  final Color fgColor, bgColor, borderColor, iconColor, descColor;

  void onTap() {
    if (disabled) return;
    onChange(!checked);
  }

  @override
  Widget build(BuildContext context) {
    return MenuItemBase(
      bgColor: bgColor,
      borderColor: borderColor,
      disabled: disabled,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                icon != null
                    ? Icon(
                        icon,
                        color: iconColor,
                      )
                    : SizedBox.shrink(),
                SizedBox(width: 12),
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      desc != null
                          ? const SizedBox(height: 4)
                          : SizedBox.shrink(),
                      desc != null
                          ? Text(
                              desc!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Fonts.rubik,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: descColor,
                                decoration: TextDecoration.none,
                              ),
                              softWrap: true,
                              textAlign: TextAlign.left,
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
              value: checked,
              activeTrackColor: ThemeColors.blue,
              inactiveTrackColor: ThemeColors.gray3,
              onChanged: (_) {
                onTap();
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
    this.descColor = ThemeColors.white3,
    this.disabled = false,
  });
  final VoidCallback onTap;
  final String title;
  final String? desc;
  final IconData? icon;
  final bool disabled;
  final Color fgColor, bgColor, iconColor, borderColor, descColor;
  @override
  Widget build(BuildContext context) {
    return MenuItemBase(
      onTap: onTap,
      borderColor: borderColor,
      disabled: disabled,
      bgColor: bgColor,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            icon != null
                ? Icon(icon, color: ThemeColors.white2)
                : SizedBox.shrink(),
            SizedBox(width: 12),
            Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: Fonts.rubik,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: fgColor,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  desc != null ? const SizedBox(height: 4) : SizedBox.shrink(),
                  desc != null
                      ? Text(
                          desc!,
                          style: TextStyle(
                            fontFamily: Fonts.rubik,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: descColor,
                            decoration: TextDecoration.none,
                          ),
                          softWrap: true,
                          textAlign: TextAlign.left,
                        )
                      : SizedBox.shrink()
                ]),
            Icon(
              Icons.chevron_right_outlined,
              color: ThemeColors.white2,
              size: 18,
            ),
          ],
        )
      ]),
    );
  }
}

class MenuItemBase extends StatelessWidget {
  const MenuItemBase(
      {super.key,
      required this.child,
      this.onTap,
      required this.bgColor,
      required this.borderColor,
      required this.disabled});
  final Widget child;
  final VoidCallback? onTap;
  final Color bgColor, borderColor;
  final bool disabled;
  static const disabledOpacity = 0.4;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: disabled ? () {} : onTap,
        child: Opacity(
          opacity: disabled ? disabledOpacity : 1,
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
          ),
        ));
  }
}
