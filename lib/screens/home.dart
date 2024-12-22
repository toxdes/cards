import 'dart:io';

import 'package:cards/screens/backup_restore/backup_main.dart';
import 'package:cards/components/home/bottom_sheet.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/cardview.dart';
import "package:cards/components/shared/icon_button.dart";
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/models/cardlist/cardlist.dart';
import 'package:cards/services/flavor_service.dart';
import 'package:cards/services/sentry_service.dart';
import 'package:cards/services/toast_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Text, IconButton;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

var contextMenu = Menu(
  items: [
    MenuItem(
      key: "show_window",
      label: 'Show Cards',
    ),
    MenuItem(label: "Exit", key: 'exit')
  ],
);

class _HomeState extends State<Home> with TrayListener, WindowListener {
  CardListModel _cards = CardListModel.the();
  bool _addNewCardFormVisible = false;

  void onCardListModelUpdate(CardListModel newModel) {
    setState(() {
      _cards = newModel;
    });
  }

  void addCard(CardModel c) {
    setState(() {
      try {
        _cards.add(c);
        _cards.save();
        ToastService.show(status: ToastStatus.success, message: "card saved");
      } catch (e, stackTrace) {
        SentryService.error(e, stackTrace);
        String message = "couldn't save card";
        if (e is CardListModelException) {
          if (e.errorCode == CLMErrorCodes.notUnique) {
            message =
                "failed to save. You already have a card with same number";
          }
        }
        ToastService.show(status: ToastStatus.error, message: message);
      }
    });
  }

  void removeCard(CardModel c) {
    setState(() {
      try {
        _cards.remove(c);
        _cards.save();
        ToastService.show(status: ToastStatus.success, message: "card deleted");
      } catch (e, stackTrace) {
        SentryService.error(e, stackTrace);
        String message = "couldn't delete card";
        if (e is CardListModelException) {
          if (e.errorCode == CLMErrorCodes.doesNotExist) {
            message = "card does not exist";
          }
        }
        ToastService.show(status: ToastStatus.error, message: message);
      }
    });
  }

  @override
  void initState() {
    // _cards.clearStorage();
    trayManager.addListener(this);
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
    trayManager.setIcon(
        Platform.isWindows ? 'assets/icon48.ico' : 'assets/icon48.png');
    trayManager.setContextMenu(contextMenu);
    _readFromStorage();
    _cards.setUpdateListener(onCardListModelUpdate);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.setSkipTaskbar(true);
    await windowManager.hide();
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      windowManager.focus();
    } else if (menuItem.key == 'exit') {
      windowManager.destroy();
    }
  }

  Future<void> _readFromStorage() async {
    await _cards.readFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
            decoration: const BoxDecoration(color: ThemeColors.gray1),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Stack(textDirection: TextDirection.ltr, children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Saved cards (${_cards.length})",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontFamily: Fonts.rubik,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: ThemeColors.white2)),
                                kIsWeb
                                    ? const SizedBox.shrink()
                                    : IconButton(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              CupertinoDialogRoute(
                                                  context: context,
                                                  builder: (context) =>
                                                      const BackupMainScreen()));
                                        },
                                        size: 32,
                                        color: ThemeColors.blue,
                                        buttonType: ButtonType.primary,
                                        iconData: Icons.share_rounded)
                              ]),
                          const SizedBox(height: 12),
                          Expanded(
                              child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: _cards.length == 0
                                ? [
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            16, 48, 16, 32),
                                        child: const Text(
                                            "You haven't added any cards yet.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: Fonts.rubik,
                                                fontWeight: FontWeight.w400,
                                                color: ThemeColors.white2)))
                                  ]
                                : _cards.getAll().map((CardModel card) {
                                    return CardView(
                                        card: card,
                                        onLongPress: (CardModel c) {
                                          removeCard(c);
                                        });
                                  }).toList(),
                          )),
                          Button(
                            text: "Add new card +",
                            color: ThemeColors.blue,
                            buttonType: ButtonType.primary,
                            alignment: Alignment.center,
                            height: 48,
                            onTap: () {
                              setState(() {
                                _addNewCardFormVisible = true;
                              });
                            },
                          )
                              .animate(
                                  autoPlay: true,
                                  onComplete: (controller) {
                                    controller.loop(count: 3);
                                  })
                              .then(delay: 10.seconds)
                              .shake(
                                duration: 600.ms,
                                rotation: 0.02,
                              ),
                        ],
                      ))),
              AddNewCardModal(
                isVisible: _addNewCardFormVisible,
                onClose: () {
                  setState(() {
                    _addNewCardFormVisible = false;
                  });
                },
                onAddNewCard: addCard,
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Text("${FlavorService.getFlavor().getLabel()}",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontFamily: Fonts.rubik,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.yellow)),
              ),
            ])),
      ),
    );
  }
}
