import 'package:cards/components/backup_restore/restore_fields_formatter.dart';
import 'package:cards/components/backup_restore/restore_fields_validator.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/textinput.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/step/step.dart';
import 'package:cards/screens/backup_restore/restore.dart';
import 'package:cards/services/backup_service.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class RestoreStepContent extends StatefulWidget {
  final RestoreStep step;
  final Function(RestoreCallbackAction action, Step step)? actionCallback;
  final Function(String key, String secret)? validateCredsCallback;
  final XFile? backupFile;

  const RestoreStepContent(
      {super.key,
      required this.step,
      required this.actionCallback,
      required this.validateCredsCallback,
      this.backupFile});

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
    }
    return const SizedBox.shrink();
  }
}
