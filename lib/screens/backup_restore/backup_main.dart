import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/components/shared/icon_button.dart' as ui;
import 'package:cards/config/fonts.dart';
import 'package:cards/screens/backup_restore/backup.dart';
import 'package:cards/screens/backup_restore/help.dart';
import 'package:cards/screens/backup_restore/restore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackupMainScreen extends StatefulWidget {
  const BackupMainScreen({super.key});
  @override
  State<StatefulWidget> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupMainScreen> {
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
              const Text("Backup and restore",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontFamily: Fonts.rubik,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.white2,
                      fontSize: 24)),
              ui.IconButton(
                size: 32,
                color: ThemeColors.white2,
                iconData: Icons.close_rounded,
                buttonType: ButtonType.ghost,
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          const SizedBox(height: 48),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Button(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoDialogRoute(
                                builder: (context) => const BackupScreen(),
                                context: context));
                      },
                      color: ThemeColors.blue,
                      text: "I want to backup my data",
                      buttonType: ButtonType.primary),
                  const SizedBox(height: 24),
                  Button(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoDialogRoute(
                                builder: (context) => const RestoreScreen(),
                                context: context));
                      },
                      color: ThemeColors.blue,
                      text: "I already have a backup",
                      buttonType: ButtonType.primary),
                  const SizedBox(height: 24),
                  Button(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoDialogRoute(
                                builder: (context) => const HelpScreen(),
                                context: context));
                      },
                      color: ThemeColors.blue,
                      text: "I have no idea",
                      buttonType: ButtonType.primary),
                ]),
          ),
        ],
      ),
    ));
  }
}
