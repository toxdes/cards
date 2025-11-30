import 'package:cards/components/preferences/menu_item.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/icon_button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/providers/preferences_notifier.dart';
import 'package:cards/screens/backup_restore/backup_main.dart';
import 'package:cards/services/auth_service.dart';
import 'package:cards/services/platform_service.dart';
import 'package:cards/services/toast_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

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
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
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
                          padding: const EdgeInsets.only(top: 2),
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
                Consumer<PreferencesNotifier>(
                  builder: (context, prefsNotifier, _) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          MenuItemWithSwitch(
                              checked: prefsNotifier.prefs.maskCardNumber,
                              icon: Icons.numbers_outlined,
                              title: "Hide card number",
                              onChange: (bool newValue) {
                                prefsNotifier.setMaskCardNumber(newValue);
                              }),
                          MenuItemWithSwitch(
                              checked: prefsNotifier.prefs.maskCVV,
                              icon: Icons.credit_card_outlined,
                              title: "Hide CVV",
                              onChange: (bool newValue) {
                                prefsNotifier.setMaskCVV(newValue);
                              }),
                          MenuItemWithSwitch(
                            checked: prefsNotifier.prefs.enableNotifications,
                            title: "Notifications",
                            disabled: false,
                            icon: Icons.notifications_outlined,
                            onChange: (bool newValue) {
                              prefsNotifier.setEnableNotifications(newValue);
                            },
                          ),
                          MenuItemWithSwitch(
                              checked: prefsNotifier.prefs.useDeviceAuth,
                              icon: Icons.lock_outlined,
                              title: "Use screen lock",
                              desc: PlatformService.isAndroid() &&
                                      !AuthService.isAuthSupported()
                                  // TODO: navigate to settings on press
                                  // TODO: update AuthNotifier on app-state changes
                                  ? "Please set up a device PIN or biometrics in your phone settings."
                                  : null,
                              descColor: ThemeColors.red,
                              disabled: !AuthService.isAuthSupported(),
                              onChange: (bool newValue) {
                                prefsNotifier.setUseDeviceAuth(newValue);
                              }),
                          MenuItem(
                            title: "Set theme",
                            icon: Icons.color_lens_outlined,
                            disabled: true,
                            onTap: () {
                              ToastService.todo();
                            },
                          ),
                          MenuItem(
                            title: "Backup and restore",
                            icon: Icons.cloud_upload_outlined,
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                  title: "Backup and Restore",
                                  builder: (context) =>
                                      const BackupMainScreen()));
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
                    );
                  },
                )
              ],
            )));
  }
}
