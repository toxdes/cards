import 'dart:io';
import 'dart:typed_data';

import 'package:cards/components/backup_restore/backup_step_content.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/step_header.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/step/step.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:cards/services/backup_service.dart';
import 'package:cards/utils/secure_storage.dart';
import 'package:cards/utils/string_utils.dart';
import 'package:flutter/material.dart' hide Step, IconButton;
import 'package:cards/components/shared/icon_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<StatefulWidget> createState() => _BackupScreenState();
}

enum BackupStepDesc { generateKey, saveKey, generateBackup, shareBackup }

class BackupStep extends Step {
  final BackupStepDesc desc;
  BackupStep(
      {required super.id,
      super.expanded,
      super.status,
      required super.title,
      required this.desc});
}

enum BackupCallbackAction { generateKey, saveKey, generateBackup, shareBackup }

class _BackupScreenState extends State<BackupScreen> {
  final List<BackupStep> _steps = <BackupStep>[];
  String _key = "";
  File? backupFile;

  @override
  void initState() {
    super.initState();
    _steps.add(BackupStep(
        id: 1,
        status: StepStatus.active,
        title: "Generate key",
        expanded: true,
        desc: BackupStepDesc.generateKey));
    _steps.add(
        BackupStep(id: 2, title: "Save key", desc: BackupStepDesc.saveKey));
    _steps.add(BackupStep(
        id: 3, title: "Generate backup", desc: BackupStepDesc.generateBackup));
    _steps.add(BackupStep(
        id: 4, title: "Share backup", desc: BackupStepDesc.shareBackup));
  }

  void requestToggleExpand(int stepId) {
    setState(() {
      for (int i = 0; i < _steps.length; ++i) {
        if (_steps[i].id == stepId) {
          if (_steps[i].status == StepStatus.completed) continue;
          _steps[i].expanded = !_steps[i].expanded;
        }
      }
    });
  }

  void generateKey(int stepId) async {
    // generate key
    _key = await BackupService.generateKey();

    // update ui
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

  void saveKey(int stepId) {
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

  void generateBackup(int stepId) async {
    CardListModel cards = CardListModel(
        storageKey: CardListModelStorageKeys.mainStorage,
        storage: const SecureStorage());
    await Future.delayed(const Duration(milliseconds: 2000));

    await cards.readFromStorage();
    // generate backup
    Uint8List encrypted = await BackupService.encrypt(
        key: _key, data: StringUtils.toBytes(cards.toJson()));

    // write to file
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final DateTime now = DateTime.now();
    final String filePath =
        "${documentsDir.path}/cards-${now.year}${now.month.toString().padLeft(2)}${now.day.toString().padLeft(2)}.db";
    File file = File(filePath);
    file = await file.writeAsBytes(encrypted, mode: FileMode.write);
    // update UI
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
      backupFile = file;
    });
  }

  void shareBackup(int stepId) async {
    Share.shareXFiles([XFile(backupFile!.path)], text: "how does this look?");
  }

  void act(BackupCallbackAction action, Step step) {
    switch (action) {
      case BackupCallbackAction.generateKey:
        {
          generateKey(step.id);
          return;
        }
      case BackupCallbackAction.saveKey:
        {
          saveKey(step.id);
          act(BackupCallbackAction.generateBackup, _steps[step.id]);
          return;
        }
      case BackupCallbackAction.generateBackup:
        {
          generateBackup(step.id);
          return;
        }
      case BackupCallbackAction.shareBackup:
        {
          shareBackup(step.id);
          return;
        }
    }
  }

  void stepActionCallback(StepAction action, int stepId) {
    if (action == StepAction.expand) {
      requestToggleExpand(stepId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                          "Backup",
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
                          BackupStepContent(
                              step: step,
                              actionCallback: act,
                              encryptionKey: _key,
                              backupFile: backupFile.toString())
                        ],
                      );
                    }),
                  ]),
            )));
  }
}
