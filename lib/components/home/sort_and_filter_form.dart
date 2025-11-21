import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/chip.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/db/sort.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/providers/card_filters.dart';
import 'package:cards/providers/card_sort_strategies.dart';
import 'package:cards/providers/cards_notifier.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:provider/provider.dart';

class SortAndFilterForm extends StatefulWidget {
  const SortAndFilterForm({super.key, required this.onApplyFilter});
  final Function(Set<String> cardTypes, Set<String> providers, Sort<CardModel>?)
      onApplyFilter;

  @override
  State<SortAndFilterForm> createState() => _SortAndFilterFormState();
}

class _SortAndFilterFormState extends State<SortAndFilterForm> {
  late Set<String> selectedCardTypes;
  late Set<String> selectedCardProviders;
  String? selectedSortBy;

  @override
  void initState() {
    super.initState();
    _loadCurrentState();
  }

  void _loadCurrentState() {
    final cardsNotifier = context.read<CardsNotifier>();
    selectedCardTypes = <String>{};
    selectedCardProviders = <String>{};

    for (var filter in cardsNotifier.getAllFilters()) {
      if (filter is CreditCardFilter) {
        selectedCardTypes.add("Credit");
      } else if (filter is DebitCardFilter) {
        selectedCardTypes.add("Debit");
      } else if (filter is VisaFilter) {
        selectedCardProviders.add("Visa");
      } else if (filter is MasterCardFilter) {
        selectedCardProviders.add("MasterCard");
      } else if (filter is RupayFilter) {
        selectedCardProviders.add("RuPay");
      }
    }

    selectedSortBy = cardsNotifier.getActiveSort().label;
  }

  void _resetForm() {
    setState(() {
      selectedCardTypes.clear();
      selectedCardProviders.clear();
      selectedSortBy = "Date Added";
    });
  }

  void _applyFiltersAndSorts() {
    Sort<CardModel>? selectedSort;

    if (selectedSortBy == "Name") {
      selectedSort = SortByName();
    } else if (selectedSortBy == "Times Used") {
      selectedSort = SortByTimesUsed();
    } else if (selectedSortBy == "Date Added") {
      selectedSort = SortByDateAdded();
    }

    widget.onApplyFilter(
        selectedCardTypes, selectedCardProviders, selectedSort);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
                color: ThemeColors.white2,
                fontFamily: Fonts.rubik,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            "Card Type",
            [
              Chip(
                checked: selectedCardTypes.contains("Credit"),
                label: "Credit",
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                onTap: () {
                  setState(() {
                    if (selectedCardTypes.contains("Credit")) {
                      selectedCardTypes.remove("Credit");
                    } else {
                      selectedCardTypes.add("Credit");
                    }
                  });
                },
              ),
              Chip(
                checked: selectedCardTypes.contains("Debit"),
                label: "Debit",
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                onTap: () {
                  setState(() {
                    if (selectedCardTypes.contains("Debit")) {
                      selectedCardTypes.remove("Debit");
                    } else {
                      selectedCardTypes.add("Debit");
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            "Provider",
            [
              Chip(
                checked: selectedCardProviders.contains("RuPay"),
                label: "RuPay",
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                onTap: () {
                  setState(() {
                    if (selectedCardProviders.contains("RuPay")) {
                      selectedCardProviders.remove("RuPay");
                    } else {
                      selectedCardProviders.add("RuPay");
                    }
                  });
                },
              ),
              Chip(
                checked: selectedCardProviders.contains("Visa"),
                label: "Visa",
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                onTap: () {
                  setState(() {
                    if (selectedCardProviders.contains("Visa")) {
                      selectedCardProviders.remove("Visa");
                    } else {
                      selectedCardProviders.add("Visa");
                    }
                  });
                },
              ),
              Chip(
                checked: selectedCardProviders.contains("MasterCard"),
                label: "MasterCard",
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                onTap: () {
                  setState(() {
                    if (selectedCardProviders.contains("MasterCard")) {
                      selectedCardProviders.remove("MasterCard");
                    } else {
                      selectedCardProviders.add("MasterCard");
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            "Sort",
            [
              Chip(
                checked: selectedSortBy == "Name",
                label: "Name",
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                onTap: () {
                  setState(() {
                    selectedSortBy =
                        selectedSortBy == "Name" ? "Date Added" : "Name";
                  });
                },
              ),
              Chip(
                checked: selectedSortBy == "Times Used",
                label: "Times Used",
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                onTap: () {
                  setState(() {
                    selectedSortBy = selectedSortBy == "Times Used"
                        ? "Date Added"
                        : "Times Used";
                  });
                },
              ),
              Chip(
                checked: selectedSortBy == "Date Added",
                label: "Date Added",
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                onTap: () {
                  setState(() {
                    selectedSortBy = "Date Added";
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Button(
                color: ThemeColors.red,
                labelColor: ThemeColors.red,
                buttonType: ButtonType.ghost,
                onTap: _resetForm,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                alignment: Alignment.center,
                height: 42,
                label: "Reset filters",
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Button(
                  color: ThemeColors.blue,
                  onTap: _applyFiltersAndSorts,
                  alignment: Alignment.center,
                  height: 42,
                  label: "Apply",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
