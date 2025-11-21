import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/material.dart' hide IconButton;
import 'package:cards/components/shared/icon_button.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<StatefulWidget> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      decoration: const BoxDecoration(color: ThemeColors.gray1),
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Help",
                textAlign: TextAlign.left,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: Fonts.rubik,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.white2,
                    fontSize: 24),
              ),
              IconButton(
                size: 32,
                color: ThemeColors.white2,
                iconData: Icons.close_rounded,
                buttonType: ButtonType.ghost,
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          )
        ],
      ),
    ));
  }
}
