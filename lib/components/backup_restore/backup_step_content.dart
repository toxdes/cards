import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/icon_button.dart';
import 'package:cards/components/shared/spinner.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/step/step.dart';
import 'package:cards/screens/backup_restore/backup.dart';
import 'package:cards/services/toast_service.dart';
import 'package:flutter/material.dart' hide Step, IconButton;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BackupStepContent extends StatefulWidget {
  final BackupStep step;
  final String encryptionKey;
  final Function(BackupCallbackAction action, Step step)? actionCallback;
  final String? backupFile;
  const BackupStepContent(
      {super.key,
      required this.step,
      this.actionCallback,
      this.backupFile,
      required this.encryptionKey});

  @override
  State<StatefulWidget> createState() => _BackupStepContentState();
}

class _BackupStepContentState extends State<BackupStepContent> {
  _formatKey(String key) {
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < key.length; ++i) {
      if (i != 0 && i != key.length && i % 4 == 0) {
        buf.write('  ');
      }
      buf.write(key[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    BackupStepDesc desc = widget.step.desc;
    if (widget.step.expanded) {
      if (desc == BackupStepDesc.generateKey) {
        return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text(
                    "A 12-digit key will be generated and used for data encryption. The key will be visible one-time during this step, and this key should be kept private.",
                    style: TextStyle(
                        color: ThemeColors.white2,
                        decoration: TextDecoration.none,
                        textBaseline: TextBaseline.alphabetic,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        fontSize: 16)),
                const SizedBox(height: 12),
                const Text(
                    "If you lose the key, you won't be able to restore the backup.",
                    style: TextStyle(
                        color: ThemeColors.white2,
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
                        if (widget.actionCallback != null) {
                          widget.actionCallback!(
                              BackupCallbackAction.generateKey, widget.step);
                        }
                      },
                      text: "I understand, continue",
                      color: ThemeColors.blue),
                )
              ],
            ));
      }
      if (desc == BackupStepDesc.saveKey) {
        return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "Following 12-digit key will be used for encryption.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: ThemeColors.white2,
                        fontSize: 16,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: const BoxDecoration(
                        color: ThemeColors.gray3,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_formatKey(widget.encryptionKey),
                            style: const TextStyle(
                                fontFamily: Fonts.rubik,
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                color: ThemeColors.white1,
                                decoration: TextDecoration.none)),
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          child: IconButton(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: widget.encryptionKey));
                                ToastService.show(
                                    status: ToastStatus.success,
                                    message: "copied to clipboard");
                              },
                              iconData: Icons.copy_outlined,
                              color: ThemeColors.blue,
                              buttonType: ButtonType.ghost,
                              size: 32),
                        )
                      ],
                    )),
                const SizedBox(height: 16),
                const Text("Keep this key safe with you.",
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
                        if (widget.actionCallback != null) {
                          widget.actionCallback!(
                              BackupCallbackAction.saveKey, widget.step);
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
                  Text("${widget.backupFile}",
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
                          if (widget.actionCallback != null) {
                            widget.actionCallback!(
                                BackupCallbackAction.saveBackupToDownloads,
                                widget.step);
                          }
                        },
                        text: "Save to downloads",
                        color: ThemeColors.blue),
                    Container(
                        margin: const EdgeInsets.only(left: 12),
                        child: Button(
                            onTap: () {
                              if (widget.actionCallback != null) {
                                widget.actionCallback!(
                                    BackupCallbackAction.shareBackup,
                                    widget.step);
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
