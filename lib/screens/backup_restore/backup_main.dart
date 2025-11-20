import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/components/shared/icon_button.dart' as ui;
import 'package:cards/components/shared/select_from_options.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/screens/backup_restore/backup.dart';
import 'package:cards/screens/backup_restore/restore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackupMainScreen extends StatefulWidget {
  const BackupMainScreen({super.key});
  @override
  State<StatefulWidget> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupMainScreen> {
  SelectOption? _selectedOption;

  void _proceedWithSelection() {
    if (_selectedOption?.key == 'backup') {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => const BackupScreen(),
              title: "Generate Backup"));
    } else if (_selectedOption?.key == 'restore') {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => const RestoreScreen(),
              title: "Restore Backup"));
    }
  }

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
                  child: ui.IconButton(
                    size: 28,
                    color: ThemeColors.white1,
                    iconData: Icons.arrow_back_rounded,
                    buttonType: ButtonType.ghost,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: const Text("Backup & Restore",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontFamily: Fonts.rubik,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.white2,
                            fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SelectFromOptions(
                      vertical: true,
                      options: [
                        SelectOption(
                          key: 'backup',
                          desc: 'I want to backup my data',
                          label: "Backup",
                          icon: Icons.backup_rounded,
                        ),
                        SelectOption(
                          key: 'restore',
                          desc: 'I already have a backup',
                          label: "Restore",
                          icon: Icons.restore_rounded,
                        ),
                      ],
                      selectedOption: _selectedOption,
                      onSelectOption: (option) {
                        setState(() {
                          _selectedOption = _selectedOption?.key == option.key
                              ? null
                              : option;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(),
                    child: Align(
                      alignment: Alignment.center,
                      child: Button(
                        onTap: _proceedWithSelection,
                        color: ThemeColors.blue,
                        label: "Continue",
                        buttonType: ButtonType.primary,
                        disabled: _selectedOption == null,
                        width: 120,
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    ));
  }
}
