import 'package:cards/components/home/add_new_card_form.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card/card.dart';
import 'package:flutter/material.dart';

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
                decoration: const BoxDecoration(color: ThemeColors.gray1),
                child: Container(
                    decoration: const BoxDecoration(
                        color: ThemeColors.gray1,
                        borderRadius: BorderRadius.only(
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
    );
  }
}
