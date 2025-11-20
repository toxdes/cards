import 'package:cards/components/home/sort_and_filter_form.dart';
import 'package:cards/components/shared/bottom_sheet.dart';
import 'package:cards/core/db/sort.dart';
import 'package:cards/models/card/card.dart';
import 'package:flutter/material.dart' hide BottomSheet;

class SortAndFilterModal extends StatelessWidget {
  const SortAndFilterModal(
      {super.key,
      required this.onClose,
      required this.isVisible,
      required this.onApplyFilter});
  final VoidCallback onClose;
  final bool isVisible;
  final Function(Set<String> cardTypes, Set<String> providers, Sort<CardModel>?)
      onApplyFilter;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        title: "Sort and Filter",
        closeLabel: "Close",
        onClose: onClose,
        isVisible: isVisible,
        heightFactor: 0.65,
        child: SortAndFilterForm(onApplyFilter: onApplyFilter));
  }
}
