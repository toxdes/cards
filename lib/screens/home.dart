import 'package:cards/components/home/add_new_card_modal.dart';
import 'package:cards/components/home/cardlist_empty.dart';
import 'package:cards/components/home/filter_controls.dart';
import 'package:cards/components/home/filter_summary.dart';
import 'package:cards/components/home/header.dart';
import 'package:cards/components/home/sort_and_filter_modal.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/cardview.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/db/sort.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/providers/card_filters.dart';
import 'package:cards/providers/cards_notifier.dart';
import 'package:cards/providers/preferences_notifier.dart';
import 'package:cards/services/auth_service.dart';
import 'package:cards/services/flavor_service.dart';
import 'package:cards/services/platform_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TrayListener, WindowListener {
  bool _addNewCardFormVisible = false;
  bool _sortAndFilterModalVisible = false;

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

  @override
  void initState() {
    super.initState();
    if (PlatformService.isDesktop()) {
      trayManager.addListener(this);
      windowManager.addListener(this);
      windowManager.setPreventClose(true);
      trayManager.setIcon(PlatformService.isWindows()
          ? 'assets/icon48.ico'
          : 'assets/icon48.png');
      trayManager.setContextMenu(getContextMenuItems());
    }
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

  void _onApplyFilter(
      Set<String> cardTypes, Set<String> providers, Sort<CardModel>? sort) {
    final cardsNotifier = context.read<CardsNotifier>();

    cardsNotifier.getAllFilters().toList().forEach((filter) {
      cardsNotifier.removeFilter(filter);
    });

    if (cardTypes.contains("Credit")) {
      cardsNotifier.addFilter(CreditCardFilter());
    }
    if (cardTypes.contains("Debit")) {
      cardsNotifier.addFilter(DebitCardFilter());
    }

    if (providers.contains("RuPay")) {
      cardsNotifier.addFilter(RupayFilter());
    }
    if (providers.contains("Visa")) {
      cardsNotifier.addFilter(VisaFilter());
    }
    if (providers.contains("MasterCard")) {
      cardsNotifier.addFilter(MasterCardFilter());
    }

    if (sort != null) {
      cardsNotifier.addSort(sort);
    } else {
      cardsNotifier.resetSort();
    }
    setState(() {
      _sortAndFilterModalVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesNotifier>(builder: (context, prefsNotifier, _) {
      return Consumer<CardsNotifier>(
        builder: (context, cardsNotifier, _) {
          List<Widget> cards =
              cardsNotifier.getFilteredCards().map((CardModel c) {
            return CardView(
                card: c,
                onLongPress: (CardModel sc) async {
                  cardsNotifier.removeCard(sc);
                });
          }).toList();
          return SafeArea(
            child: Center(
              child: Container(
                  decoration: const BoxDecoration(color: ThemeColors.gray1),
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Stack(textDirection: TextDirection.ltr, children: [
                    Container(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                        child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Header(),
                                const SizedBox(height: 6),
                                cardsNotifier.getCardsCount() > 0
                                    ? FilterControls(
                                        onTuneIconTap: () {
                                          setState(() {
                                            _sortAndFilterModalVisible = true;
                                          });
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                const FilterSummary(),
                                Expanded(
                                    child: ListView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  children:
                                      cards.isEmpty ? [CardListEmpty()] : cards,
                                )),
                                Button(
                                  label: "Add new card +",
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
                                SizedBox(height: 12),
                              ],
                            ))),
                    AddNewCardModal(
                      isVisible: _addNewCardFormVisible,
                      onClose: () {
                        setState(() {
                          _addNewCardFormVisible = false;
                        });
                      },
                      onAddNewCard: (CardModel card) async {
                        await cardsNotifier.addCard(card);
                        if (mounted) {
                          setState(() {
                            _addNewCardFormVisible = false;
                          });
                        }
                      },
                    ),
                    SortAndFilterModal(
                      isVisible: _sortAndFilterModalVisible,
                      onClose: () {
                        setState(() {
                          _sortAndFilterModalVisible = false;
                        });
                      },
                      onApplyFilter: _onApplyFilter,
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
        },
      );
    });
  }
}
