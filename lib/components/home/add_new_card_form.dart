import 'package:cards/components/shared/button.dart';
import 'package:cards/models/card.dart';
import 'package:flutter/material.dart';

class AddNewCardForm extends StatefulWidget {
  const AddNewCardForm({super.key, required this.onSubmit});
  final ValueSetter<CardModel> onSubmit;
  @override
  State<AddNewCardForm> createState() => _AddNewCardFormState();
}

class _AddNewCardFormState extends State<AddNewCardForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("TODO: FORM ELEMENTS HERE"),
            const SizedBox(height: 20),
            Button(
                onTap: () {
                  widget.onSubmit(CardModel.random());
                },
                text: "Submit random card")
          ],
        ));
  }
}
