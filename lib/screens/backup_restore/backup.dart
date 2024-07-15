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
import 'package:cards/services/toast_service.dart';
import 'package:cards/utils/file_utils.dart';
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

enum BackupStepDesc { generateCreds, saveCreds, generateBackup, shareBackup }

class BackupStep extends Step {
  final BackupStepDesc desc;
  BackupStep(
      {required super.id,
      super.expanded,
      super.status,
      required super.title,
      required this.desc});
}

enum BackupCallbackAction {
  generateCreds,
  saveCreds,
  generateBackup,
  shareBackup,
  saveBackupToDownloads
}

class _BackupScreenState extends State<BackupScreen> {
  final List<BackupStep> _steps = <BackupStep>[];
  String _key = "";
  String _secret = "";
  File? backupFile;

  @override
  void initState() {
    super.initState();
    _steps.add(BackupStep(
        id: 1,
        status: StepStatus.active,
        title: "Generate key",
        expanded: true,
        desc: BackupStepDesc.generateCreds));
    _steps.add(
        BackupStep(id: 2, title: "Save key", desc: BackupStepDesc.saveCreds));
    _steps.add(BackupStep(
        id: 3, title: "Generate backup", desc: BackupStepDesc.generateBackup));
    _steps.add(BackupStep(
        id: 4, title: "Share backup", desc: BackupStepDesc.shareBackup));
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

  void generateCreds(int stepId) async {
    // generate key
    _key = await BackupService.generateKey();

    // generate secret (salt)
    _secret = await BackupService.generateSalt();

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

  void saveCreds(int stepId) {
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
        key: _key, data: StringUtils.toBytes(cards.toJson()), salt: _secret);

    // write to file
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final DateTime now = DateTime.now();
    final String filePath =
        "${documentsDir.path}/cards-${now.year}${now.month.toString().padLeft(2, "0")}${now.day.toString().padLeft(2, "0")}.bin";
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
    Share.shareXFiles([XFile(backupFile!.path)],
        text: "Share cards backup file...");
  }

  void saveBackupToDownloads(int stepId) async {
    try {
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        String downloadsPath = "/storage/emulated/0/Download";
        bool dirExists = Directory(downloadsPath).existsSync();
        if (dirExists) {
          downloadsDir = Directory(downloadsPath);
        } else {
          downloadsPath = "storage/emulated/0/Downloads";
          downloadsDir = Directory(downloadsPath);
        }
      } else {
        downloadsDir = await getDownloadsDirectory();
      }
      if (downloadsDir == null) {
        throw UnsupportedError("");
      }
      downloadsDir = await downloadsDir.create();
      String fileName = FileUtils.getFileName(backupFile!);
      File file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(backupFile!.readAsBytesSync());
      ToastService.show(
          message: "Saved to downloads", status: ToastStatus.success);
    } catch (e) {
      String message = "";
      if (e is UnsupportedError) {
        message = "Feature is not available on this platform.";
      } else {
        message = e.toString();
      }
      ToastService.show(status: ToastStatus.error, message: message);
    }
  }

  void act(BackupCallbackAction action, Step step) {
    switch (action) {
      case BackupCallbackAction.generateCreds:
        {
          generateCreds(step.id);
          return;
        }
      case BackupCallbackAction.saveCreds:
        {
          saveCreds(step.id);
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
      case BackupCallbackAction.saveBackupToDownloads:
        {
          saveBackupToDownloads(step.id);
          return;
        }
    }
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
                              encryptionSecret: _secret,
                              backupFileName: backupFile == null
                                  ? ''
                                  : FileUtils.getFileName(backupFile!))
                        ],
                      );
                    }),
                  ]),
            )));
  }
}
