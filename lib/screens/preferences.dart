import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/icon_button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/services/toast_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

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
      this.bgColor = ThemeColors.gray1});
  final ValueSetter<bool> onChange;
  final bool checked;
  final String title;
  final String? desc;
  final IconData? icon;
  final Color fgColor, bgColor, iconColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onChange(!checked);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          height: 64,
          decoration: BoxDecoration(
              color: bgColor,
              border: BoxBorder.fromLTRB(
                  bottom: BorderSide(color: ThemeColors.gray3, width: 1),
                  top: BorderSide(color: ThemeColors.gray3, width: 1))),
          width: double.infinity,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
              },
            )
          ]),
        ));
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
  });
  final VoidCallback onTap;
  final String title;
  final String? desc;
  final IconData? icon;
  final Color fgColor, bgColor, iconColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          height: 64,
          decoration: BoxDecoration(
              border: BoxBorder.fromLTRB(
                  bottom: BorderSide(color: ThemeColors.gray3, width: 1),
                  top: BorderSide(color: ThemeColors.gray3, width: 1))),
          width: double.infinity,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
          ]),
        ));
  }
}

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            decoration: const BoxDecoration(color: ThemeColors.gray1),
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                              size: 28,
                              color: ThemeColors.white2,
                              iconData: Icons.arrow_back_rounded,
                              buttonType: ButtonType.ghost,
                              onTap: () {
                                Navigator.pop(context);
                              }),
                        ),
                        Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: const Text(
                            "Preferences",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                fontFamily: Fonts.rubik,
                                fontWeight: FontWeight.w600,
                                color: ThemeColors.white2,
                                fontSize: 18),
                          ),
                        ))
                      ],
                    )),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      MenuItemWithSwitch(
                          checked: true,
                          icon: Icons.numbers_outlined,
                          title: "Mask Card Number",
                          onChange: (bool newValue) {
                            ToastService.todo();
                          }),
                      MenuItemWithSwitch(
                          checked: true,
                          icon: Icons.credit_card_outlined,
                          title: "Mask CVV",
                          onChange: (bool newValue) {
                            ToastService.todo();
                          }),
                      MenuItem(
                        title: "Notifications",
                        icon: Icons.notifications_outlined,
                        onTap: () {
                          ToastService.todo();
                        },
                      ),
                      MenuItem(
                          icon: Icons.lock_outlined,
                          title: "Security",
                          onTap: () {
                            ToastService.todo();
                          }),
                      MenuItem(
                        title: "Set theme",
                        icon: Icons.color_lens_outlined,
                        onTap: () {
                          ToastService.todo();
                        },
                      ),
                      MenuItem(
                        title: "Backup and restore",
                        icon: Icons.cloud_upload_outlined,
                        onTap: () {
                          ToastService.todo();
                        },
                      ),
                      MenuItem(
                        title: "Feedback",
                        icon: Icons.feedback_outlined,
                        onTap: () {
                          ToastService.todo();
                        },
                      ),
                    ],
                  ),
                )
              ],
            )));
  }
}
