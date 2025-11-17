import 'package:cards/components/backup_restore/card_list_diff_summary.dart';
import 'package:cards/components/backup_restore/restore_fields_formatter.dart';
import 'package:cards/components/backup_restore/restore_fields_validator.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/select_from_options.dart';
import 'package:cards/components/shared/spinner.dart';
import 'package:cards/components/shared/textinput.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/restore/restore_strategy.dart';
import 'package:cards/core/step/step.dart';
import 'package:cards/repositories/card_repository.dart';
import 'package:cards/screens/backup_restore/restore.dart';
import 'package:cards/services/backup_service.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/material.dart' hide Step, IconButton;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RestoreStepContent extends StatefulWidget {
  final RestoreStep step;
  final Function(RestoreCallbackAction action, Step step)? actionCallback;
  final Function(String key, String secret)? validateCredsCallback;
  final XFile? backupFile;
  final CardRepositoryDiffResult? diffResult;
  final List<RestoreStrategy> restoreStrategyOptions;
  final RestoreStrategy? selectedRestoreStrategy;
  final Function(RestoreStrategy selectedStrategy) onSelectRestoreStrategy;

  const RestoreStepContent(
      {super.key,
      required this.step,
      required this.actionCallback,
      required this.validateCredsCallback,
      required this.backupFile,
      required this.restoreStrategyOptions,
      required this.selectedRestoreStrategy,
      required this.onSelectRestoreStrategy,
      this.diffResult});

  @override
  State<RestoreStepContent> createState() => _RestoreStepContentState();
}

class _RestoreStepContentState extends State<RestoreStepContent> {
  final TextInputFormatter _secretFormatter =
      RestoreFieldsFormatter.secretFormatter();
  final TextInputFormatter _keyFormatter =
      RestoreFieldsFormatter.keyFormatter();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  void updateFormValidationStatus() {
    bool newIsFormValid =
        _formKey.currentState != null && _formKey.currentState!.validate();
    if (newIsFormValid != _isFormValid) {
      setState(() {
        _isFormValid = newIsFormValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    RestoreStep step = widget.step;
    XFile? backupFile = widget.backupFile;
    void Function(RestoreCallbackAction action, Step step)? actionCallback =
        widget.actionCallback;
    if (step.expanded) {
      if (step.desc == RestoreStepDesc.chooseBackupFile) {
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            children: [
              const Text(
                "Choose a backup file generated earlier with this app. Supported backup files have .bin extension.",
                style: TextStyle(
                    fontFamily: Fonts.rubik,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: ThemeColors.white1),
              ),
              const SizedBox(height: 12),
              backupFile != null
                  ? Text(
                      "Chosen: ${backupFile.name}",
                      style: const TextStyle(
                          fontFamily: Fonts.rubik,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                          color: ThemeColors.white1),
                    )
                  : const SizedBox.shrink(),
              SizedBox(height: backupFile != null ? 12 : 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    onTap: () {
                      if (actionCallback != null) {
                        actionCallback(
                            RestoreCallbackAction.chooseBackupFile, step);
                      }
                    },
                    text: backupFile != null ? "Change" : "Choose file",
                    color: ThemeColors.white2,
                    textColor: ThemeColors.gray1,
                  ),
                  SizedBox(
                    width: backupFile != null ? 12 : 0,
                  ),
                  backupFile != null
                      ? Button(
                          onTap: () {
                            if (actionCallback != null) {
                              actionCallback(
                                  RestoreCallbackAction.nextStep, step);
                            }
                          },
                          text: "Continue",
                          color: ThemeColors.blue,
                        )
                      : const SizedBox.shrink()
                ],
              )
            ],
          ),
        );
      }
      if (step.desc == RestoreStepDesc.enterCreds) {
        return Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              children: [
                TextInputField(
                  title: "Secret",
                  helper: "All good!",
                  hint: BackupService.getSecretShape(),
                  keyboardType: TextInputType.text,
                  inputFormatters: [_secretFormatter],
                  validator: RestoreFieldsValidator.secret,
                  controller: _secretController,
                  textCapitalization: TextCapitalization.characters,
                  updateFormStatus: updateFormValidationStatus,
                ),
                const SizedBox(height: 16),
                TextInputField(
                  title: "Key",
                  helper: "All good!",
                  hint: BackupService.getKeyShape(),
                  keyboardType: TextInputType.text,
                  inputFormatters: [_keyFormatter],
                  validator: RestoreFieldsValidator.key,
                  controller: _keyController,
                  textCapitalization: TextCapitalization.characters,
                  updateFormStatus: updateFormValidationStatus,
                ),
                const SizedBox(height: 16),
                Container(
                  alignment: Alignment.centerRight,
                  child: Button(
                    onTap: () async {
                      if (actionCallback != null) {
                        await widget.validateCredsCallback!(
                            StringUtils.removeAll(_keyController.text,
                                BackupService.keySeparator),
                            StringUtils.removeAll(_secretController.text,
                                BackupService.keySeparator));
                        actionCallback(RestoreCallbackAction.nextStep, step);
                      }
                    },
                    text: "Continue",
                    disabled: !_isFormValid,
                    color: ThemeColors.blue,
                  ),
                )
              ],
            ),
          ),
        );
      }
      if (step.desc == RestoreStepDesc.chooseRestoreStrategy) {
        return Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Backup file we just decrypted has ",
                    style: TextStyle(
                        fontFamily: Fonts.rubik,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                        color: ThemeColors.white1)),
                CardListDiffSummary(result: widget.diffResult!),
                const Text(
                  "How would you like to restore the backup?",
                  style: TextStyle(
                      fontFamily: Fonts.rubik,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                      color: ThemeColors.white1),
                ),
                SelectFromOptions(
                    options: widget.restoreStrategyOptions
                        .map((RestoreStrategy strategy) {
                      return SelectOption(
                          key: strategy.key,
                          label: strategy.label,
                          desc: strategy.desc);
                    }).toList(),
                    selectedOption: widget.selectedRestoreStrategy != null
                        ? SelectOption(
                            key: widget.selectedRestoreStrategy!.key,
                            label: widget.selectedRestoreStrategy!.label,
                            desc: widget.selectedRestoreStrategy!.desc)
                        : null,
                    onSelectOption: (SelectOption selected) {
                      RestoreStrategy? res;
                      for (int i = 0;
                          i < widget.restoreStrategyOptions.length;
                          ++i) {
                        if (widget.restoreStrategyOptions[i].key ==
                            selected.key) {
                          res = widget.restoreStrategyOptions[i];
                          break;
                        }
                      }
                      if (res != null) {
                        widget.onSelectRestoreStrategy(res);
                      }
                    }),
                const SizedBox(height: 16),
                Container(
                  alignment: Alignment.centerRight,
                  child: Button(
                      color: ThemeColors.blue,
                      text: "Continue",
                      onTap: () {
                        if (actionCallback != null) {
                          actionCallback(RestoreCallbackAction.restore, step);
                        }
                      },
                      disabled: widget.selectedRestoreStrategy == null),
                )
              ],
            ));
      }
      if (step.desc == RestoreStepDesc.restore) {
        return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spinner(color: ThemeColors.white2, size: 14),
                  const SizedBox(height: 24),
                  const Text("Restoring backup...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeColors.white1,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        textBaseline: TextBaseline.alphabetic,
                      )),
                  const SizedBox(height: 8),
                  Text("Strategy: ${widget.selectedRestoreStrategy!.label}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ThemeColors.white2,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                        fontFamily: Fonts.rubik,
                        fontWeight: FontWeight.w400,
                        textBaseline: TextBaseline.alphabetic,
                      ))
                ]));
      }
      if (step.desc == RestoreStepDesc.restoreCompleted) {
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
                  const Text("Restore successful",
                      style: TextStyle(
                        fontFamily: Fonts.rubik,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        color: ThemeColors.white1,
                      )),
                  const SizedBox(height: 4),
                  const Text(
                      "Your backup has been restored. You can close this now.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: Fonts.rubik,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                        color: ThemeColors.white2,
                      )),
                  const SizedBox(height: 24)
                ]));
      }
    }
    return const SizedBox.shrink();
  }
}
