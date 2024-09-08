import 'package:cards/components/home/add_new_card_form.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card/card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddNewCardModal extends StatefulWidget {
  const AddNewCardModal(
      {super.key,
      required this.isVisible,
      required this.onClose,
      required this.onAddNewCard});
  final bool isVisible;
  final VoidCallback onClose;
  final ValueSetter<CardModel> onAddNewCard;

  @override
  State<AddNewCardModal> createState() => _AddNewFormModalState();
}

class _AddNewFormModalState extends State<AddNewCardModal> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return Container();
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(children: [
            Positioned.fill(
              child: Container(
                decoration:
                    BoxDecoration(color: ThemeColors.gray1.withOpacity(0.94)),
                padding: const EdgeInsets.only(top: 60),
                child: Container(
                    decoration: BoxDecoration(
                        color: ThemeColors.gray1,
                        border: Border(
                            top: BorderSide(
                                width: 2,
                                color: ThemeColors.blue.withOpacity(0.8))),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24))),
                    margin: const EdgeInsets.only(top: 0),
                    alignment: Alignment.center,
                    child: Container(
                      padding:
                          const EdgeInsets.only(top: 24, left: 32, right: 32),
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Add new card",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: Fonts.rubik,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeColors.white2)),
                              Button(
                                color: ThemeColors.red,
                                text: "Close",
                                onTap: widget.onClose,
                                buttonType: ButtonType.ghost,
                              )
                            ]),
                        AddNewCardForm(
                          onSubmit: (CardModel card) {
                            widget.onAddNewCard(card);
                            widget.onClose();
                          },
                        ),
                      ]),
                    )),
              ),
            ),
          ])),
    )
        .animate(autoPlay: true)
        .slideY(duration: 240.ms, curve: Curves.easeOutExpo, begin: 1, end: 0);
  }
}
