import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/icon_button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/screens/backup_restore/backup_main.dart';
import 'package:cards/screens/preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide IconButton;

class Header extends StatelessWidget {
  const Header({super.key});
  void navigateToBackupRestore(BuildContext context) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            title: "Backup and Restore",
            builder: (context) => const BackupMainScreen()));
  }

  void navigateToPreferences(BuildContext context) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            title: "Preferences",
            builder: (context) => const PreferencesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: ThemeColors.red,
      padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text("Saved cards",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: Fonts.rubik,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.white2)),
        ),
        kIsWeb
            ? const SizedBox.shrink()
            : Container(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    IconButton(
                        onTap: () {
                          navigateToBackupRestore(context);
                        },
                        size: 28,
                        color: ThemeColors.white1,
                        buttonType: ButtonType.primary,
                        iconData: Icons.backup_outlined),
                    SizedBox(width: 8),
                    IconButton(
                        onTap: () {
                          navigateToPreferences(context);
                        },
                        size: 28,
                        color: ThemeColors.white1,
                        buttonType: ButtonType.primary,
                        iconData: Icons.tune_outlined),
                  ],
                ))
      ]),
    );
  }
}
