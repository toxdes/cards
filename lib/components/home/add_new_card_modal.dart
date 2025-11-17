import 'package:cards/components/home/add_new_card_form.dart';
import 'package:cards/components/shared/bottom_sheet.dart';
import 'package:cards/models/card/card.dart';
import 'package:flutter/material.dart' hide BottomSheet;

class AddNewCardModal extends StatelessWidget {
  const AddNewCardModal(
      {super.key,
      required this.onClose,
      required this.onAddNewCard,
      required this.isVisible});
  final VoidCallback onClose;
  final ValueSetter<CardModel> onAddNewCard;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        title: "Add new card",
        closeLabel: "Cancel",
        onClose: onClose,
        isVisible: isVisible,
        child: AddNewCardForm(onSubmit: onAddNewCard));
  }
}
