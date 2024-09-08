import 'dart:typed_data';

import 'package:cards/components/backup_restore/retore_step_content.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/step_header.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/step/step.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:cards/models/cardlist/cardlist_json_encoder.dart';
import 'package:cards/services/backup_service.dart';
import 'package:cards/services/file_service.dart';
import 'package:cards/services/toast_service.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/material.dart' hide IconButton, Step;
import 'package:cards/components/shared/icon_button.dart';
import 'package:share_plus/share_plus.dart';

enum RestoreStepDesc {
  chooseBackupFile,
  enterCreds,
  chooseRestoreStrategy,
  restore
}

class RestoreStep extends Step {
  final RestoreStepDesc desc;
  RestoreStep(
      {required super.id,
      super.expanded,
      super.status,
      required super.title,
      required this.desc});
}

enum RestoreCallbackAction { chooseBackupFile, nextStep }

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});
  @override
  State<StatefulWidget> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  final List<RestoreStep> _steps = <RestoreStep>[];
  XFile? _backupFile;

  @override
  void initState() {
    super.initState();
    _steps.add(RestoreStep(
        desc: RestoreStepDesc.chooseBackupFile,
        status: StepStatus.active,
        expanded: true,
        title: "Choose backup file",
        id: 1));
    _steps.add(RestoreStep(
        desc: RestoreStepDesc.enterCreds, title: "Enter credentials", id: 2));
    _steps.add(RestoreStep(
        desc: RestoreStepDesc.chooseRestoreStrategy,
        title: "Choose restore strategy",
        id: 3));
    _steps.add(
        RestoreStep(desc: RestoreStepDesc.restore, title: "Restore", id: 4));
  }

  void requestToggleExpand(int stepId) {
    setState(() {
      for (int i = 0; i < _steps.length; ++i) {
        if (_steps[i].id == stepId) {
          if (_steps[i].status != StepStatus.active) continue;
          _steps[i].expanded = !_steps[i].expanded;
        }
      }
    });
  }

  void stepActionCallback(StepAction action, int stepId) {
    switch (action) {
      case StepAction.expand:
        {
          requestToggleExpand(stepId);
          return;
        }
    }
  }

  void chooseFile(int stepId) async {
    XFile? file = await FileService.chooseFile();
    // update UI
    if (file != null) {
      setState(() {
        _backupFile = file;
      });
    }
  }

  void nextStep(int stepId) {
    setState(() {
      for (int i = 0; i < _steps.length; ++i) {
        if (stepId == _steps[i].id) {
          // mark current step as complete
          _steps[i].status = StepStatus.completed;
          _steps[i].expanded = false;
          // expand and make next step active if it exists
          if (i + 1 < _steps.length) {
            _steps[i + 1].status = StepStatus.active;
            _steps[i + 1].expanded = true;
          }
        }
      }
    });
  }

  void validateCredentials(String key, String secret) async {
    try {
      Uint8List fileContent = await _backupFile!.readAsBytes();
      Uint8List decryptedBytes = await BackupService.decrypt(
          key: key, data: fileContent, salt: secret);
      String decrypted = StringUtils.fromBytes(decryptedBytes);
      CardListModelJsonEncoder encoder = CardListModelJsonEncoder();
      CardListModel cards = encoder.decode(decrypted);
      ToastService.show(
          message: "Card has : ${cards.getAll().length} cards",
          status: ToastStatus.success);
    } catch (e) {
      String message = "Failed to decrypt ${_backupFile!.name}";
      debugPrint("ERROR $e");
      if (e is BackupServiceException &&
          e.errorCode == BackupServiceErrorCodes.invalidKey) {
        message = "Cannot decrypt, credentials are invalid";
      }

      ToastService.show(message: message, status: ToastStatus.error);
      ToastService.show(message: e.toString(), status: ToastStatus.error);
      rethrow;
    }
  }

  void act(RestoreCallbackAction action, Step step) {
    switch (action) {
      case RestoreCallbackAction.chooseBackupFile:
        {
          chooseFile(step.id);
          return;
        }
      case RestoreCallbackAction.nextStep:
        {
          nextStep(step.id);
          return;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
          child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: Container(
          decoration: const BoxDecoration(color: ThemeColors.gray1),
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Restore",
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
                ),
                ..._steps.map((step) {
                  return Column(
                    children: [
                      StepHeader(
                          status: step.status,
                          stepId: step.id,
                          title: step.title,
                          actionCallback: stepActionCallback),
                      const SizedBox(height: 24),
                      RestoreStepContent(
                        step: step,
                        actionCallback: act,
                        backupFile: _backupFile,
                        validateCredsCallback: validateCredentials,
                      )
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
