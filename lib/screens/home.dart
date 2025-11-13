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
import 'package:cards/services/platform_service.dart';
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

enum CardFilter { all, credit, debit }

class _HomeState extends State<Home> with TrayListener, WindowListener {
  CardListModel _cards = CardListModel.the();
  bool _addNewCardFormVisible = false;
  CardFilter _activeCardFilter = CardFilter.all;

  Menu getContextMenuItems() {
    return Menu(
      items: [
        MenuItem(
          key: "show_window",
          label: 'Show Cards',
        ),
        MenuItem(label: "Exit", key: 'exit')
      ],
    );
  }

  void onCardListModelUpdate(CardListModel newModel) {
    setState(() {
      _cards = newModel;
    });
  }

  void setCardFilter(CardFilter newFilter) {
    setState(() {
      _activeCardFilter = newFilter;
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
    if (PlatformService.isDesktop()) {
      trayManager.addListener(this);
      windowManager.addListener(this);
      windowManager.setPreventClose(true);
      trayManager.setIcon(PlatformService.isWindows()
          ? 'assets/icon48.ico'
          : 'assets/icon48.png');
      trayManager.setContextMenu(getContextMenuItems());
    }
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
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == 'exit') {
      await windowManager.setClosable(true);
      await windowManager.close();
      await windowManager.destroy();
    }
  }

  Future<void> _readFromStorage() async {
    await _cards.readFromStorage();
  }

  bool isDebitCard(CardModel card) {
    return card.getTitle().toLowerCase().contains("debit");
  }

  bool matchesFilterCriteria(CardModel card) {
    if (isDebitCard(card)) {
      return _activeCardFilter != CardFilter.credit;
    }
    return _activeCardFilter != CardFilter.debit;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> visibleCards = _cards.getAll().where((CardModel card) {
      return matchesFilterCriteria(card);
    }).map((CardModel card) {
      return CardView(
          card: card,
          onLongPress: (CardModel c) {
            removeCard(c);
          });
    }).toList();
    return SafeArea(
      child: Center(
        child: Container(
            decoration: const BoxDecoration(color: ThemeColors.gray1),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Stack(textDirection: TextDirection.ltr, children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            // color: ThemeColors.red,
                            padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
                            child: Stack(children: [
                              Center(
                                child: Text("Saved cards",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: Fonts.rubik,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: ThemeColors.white2)),
                              ),
                              kIsWeb
                                  ? const SizedBox.shrink()
                                  : Container(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    title: "Backup and Restore",
                                                    builder: (context) =>
                                                        const BackupMainScreen()));
                                          },
                                          size: 28,
                                          color: ThemeColors.white1,
                                          buttonType: ButtonType.primary,
                                          iconData: Icons.backup_rounded))
                            ]),
                          ),
                          const SizedBox(height: 6),
                          _cards.length > 0
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      child: Button(
                                          buttonType: _activeCardFilter ==
                                                  CardFilter.all
                                              ? ButtonType.primary
                                              : ButtonType.outline,
                                          text: _activeCardFilter ==
                                                  CardFilter.all
                                              ? "All (${visibleCards.length})"
                                              : "All",
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 4, 12, 4),
                                          onTap: () {
                                            setCardFilter(CardFilter.all);
                                          },
                                          textColor: _activeCardFilter ==
                                                  CardFilter.all
                                              ? ThemeColors.gray1
                                              : ThemeColors.white1,
                                          color: ThemeColors.white1),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      child: Button(
                                          buttonType: _activeCardFilter ==
                                                  CardFilter.debit
                                              ? ButtonType.primary
                                              : ButtonType.outline,
                                          text: _activeCardFilter ==
                                                  CardFilter.debit
                                              ? "Debit (${visibleCards.length})"
                                              : "Debit",
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 4, 12, 4),
                                          onTap: () {
                                            setCardFilter(CardFilter.debit);
                                          },
                                          textColor: _activeCardFilter ==
                                                  CardFilter.debit
                                              ? ThemeColors.gray1
                                              : ThemeColors.white1,
                                          color: ThemeColors.white1),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      child: Button(
                                          buttonType: _activeCardFilter ==
                                                  CardFilter.credit
                                              ? ButtonType.primary
                                              : ButtonType.outline,
                                          text: _activeCardFilter ==
                                                  CardFilter.credit
                                              ? "Credit (${visibleCards.length})"
                                              : "Credit",
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 4, 12, 4),
                                          onTap: () {
                                            setCardFilter(CardFilter.credit);
                                          },
                                          textColor: _activeCardFilter ==
                                                  CardFilter.credit
                                              ? ThemeColors.gray1
                                              : ThemeColors.white1,
                                          color: ThemeColors.white1),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
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
                                        child: Text(
                                            _cards.length == 0
                                                ? "You haven't added any cards yet."
                                                : "No cards to show",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontFamily: Fonts.rubik,
                                                fontWeight: FontWeight.w400,
                                                color: ThemeColors.white2)))
                                  ]
                                : visibleCards,
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
                child: Text(FlavorService.getFlavor().getLabel(),
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
