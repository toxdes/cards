import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/icon_button.dart';
import 'package:cards/components/shared/spinner.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/step/step.dart';
import 'package:cards/screens/backup_restore/backup.dart';
import 'package:cards/services/backup_service.dart';
import 'package:cards/services/toast_service.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/material.dart' hide Step, IconButton;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BackupStepContent extends StatelessWidget {
  final BackupStep step;
  final String encryptionKey;
  final String encryptionSecret;
  final Function(BackupCallbackAction action, Step step)? actionCallback;
  final String? backupFileName;
  const BackupStepContent(
      {super.key,
      required this.step,
      this.actionCallback,
      this.backupFileName,
      required this.encryptionKey,
      required this.encryptionSecret});

  @override
  Widget build(BuildContext context) {
    BackupStepDesc desc = step.desc;
    String formattedEncryptionSecret =
        StringUtils.formatKey(encryptionSecret, BackupService.keySeparator);
    String formattedEncryptionKey =
        StringUtils.formatKey(encryptionKey, BackupService.keySeparator);
    if (step.expanded) {
      if (desc == BackupStepDesc.generateCreds) {
        return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text(
                    "A ${BackupService.saltLength} characters long secret, and ${BackupService.keyLength} characters long key will be generated and will be used as credentials for data encryption.",
                    style: TextStyle(
                        color: ThemeColors.white2,
                        decoration: TextDecoration.none,
                        textBaseline: TextBaseline.alphabetic,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        fontSize: 16)),
                const SizedBox(height: 12),
                const Text(
                    "If you lose these creds, you won't be able to restore the backup.",
                    style: TextStyle(
                        color: ThemeColors.white2,
                        decoration: TextDecoration.none,
                        textBaseline: TextBaseline.alphabetic,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        fontSize: 16)),
                const SizedBox(height: 12),
                const Text(
                    "These creds will be visible one-time during this step, and should be kept private.",
                    style: TextStyle(
                        color: ThemeColors.red2,
                        decoration: TextDecoration.none,
                        textBaseline: TextBaseline.alphabetic,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        fontSize: 16)),
                const SizedBox(height: 24),
                Container(
                  alignment: Alignment.centerRight,
                  child: Button(
                      onTap: () {
                        if (actionCallback != null) {
                          actionCallback!(
                              BackupCallbackAction.generateCreds, step);
                        }
                      },
                      text: "I understand, continue",
                      color: ThemeColors.blue),
                )
              ],
            ));
      }
      if (desc == BackupStepDesc.saveCreds) {
        return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text("Following creds will be used for encryption.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: ThemeColors.white2,
                        fontSize: 16,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: const BoxDecoration(
                      color: ThemeColors.gray3,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text("Secret",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: ThemeColors.white2,
                              fontSize: 12,
                              fontFamily: Fonts.rubik,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(formattedEncryptionSecret,
                              style: const TextStyle(
                                  fontFamily: Fonts.rubik,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: ThemeColors.white1,
                                  decoration: TextDecoration.none)),
                          Container(
                            margin: const EdgeInsets.only(left: 12),
                            child: IconButton(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: formattedEncryptionSecret));
                                  ToastService.show(
                                      status: ToastStatus.success,
                                      message: "secret copied to clipboard");
                                },
                                iconData: Icons.copy_outlined,
                                color: ThemeColors.blue,
                                buttonType: ButtonType.ghost,
                                size: 32),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text("Key",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: ThemeColors.white2,
                              fontSize: 12,
                              fontFamily: Fonts.rubik,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(formattedEncryptionKey,
                              style: const TextStyle(
                                  fontFamily: Fonts.rubik,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: ThemeColors.white1,
                                  decoration: TextDecoration.none)),
                          Container(
                            margin: const EdgeInsets.only(left: 12),
                            child: IconButton(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: formattedEncryptionKey));
                                  ToastService.show(
                                      status: ToastStatus.success,
                                      message: "key copied to clipboard");
                                },
                                iconData: Icons.copy_outlined,
                                color: ThemeColors.blue,
                                buttonType: ButtonType.ghost,
                                size: 32),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Keep this creds safe with you.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: ThemeColors.white2,
                        fontSize: 16,
                        textBaseline: TextBaseline.alphabetic,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none)),
                const SizedBox(height: 24),
                Container(
                  alignment: Alignment.centerRight,
                  child: Button(
                      onTap: () {
                        if (actionCallback != null) {
                          actionCallback!(BackupCallbackAction.saveCreds, step);
                        }
                      },
                      text: "I saved the key, continue",
                      color: ThemeColors.blue),
                )
              ],
            ));
      }
      if (desc == BackupStepDesc.generateBackup) {
        return Container(
            padding: const EdgeInsets.all(12),
            child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spinner(color: ThemeColors.white2, size: 14),
                  SizedBox(height: 24),
                  Text("Generating backup...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeColors.white2,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        textBaseline: TextBaseline.alphabetic,
                      ))
                ]));
      }
      if (desc == BackupStepDesc.shareBackup) {
        return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                          color: ThemeColors.green, size: 84)
                      .animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOutExpo)
                      .scaleXY(begin: 2, end: 1, duration: 800.ms)
                      .rotate(
                        begin: 0.1,
                        end: 0,
                        curve: Curves.easeOutExpo,
                        duration: 800.ms,
                        delay: 0.ms,
                      )
                      .shimmer(
                        delay: 1400.ms,
                        duration: 1400.ms,
                      ),
                  const SizedBox(height: 16),
                  const Text("Backup generated",
                      style: TextStyle(
                        fontFamily: Fonts.rubik,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        color: ThemeColors.white1,
                      )),
                  const SizedBox(height: 4),
                  Text("$backupFileName",
                      style: const TextStyle(
                        fontFamily: Fonts.rubik,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                        color: ThemeColors.white2,
                      )),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Button(
                        onTap: () {
                          if (actionCallback != null) {
                            actionCallback!(
                                BackupCallbackAction.saveBackupToDownloads,
                                step);
                          }
                        },
                        text: "Save to downloads",
                        color: ThemeColors.blue),
                    Container(
                        margin: const EdgeInsets.only(left: 12),
                        child: Button(
                            onTap: () {
                              if (actionCallback != null) {
                                actionCallback!(
                                    BackupCallbackAction.shareBackup, step);
                              }
                            },
                            text: "Share",
                            textColor: ThemeColors.gray1,
                            color: ThemeColors.white2)),
                  ])
                ]));
      }
    }
    return const SizedBox.shrink();
  }
}
