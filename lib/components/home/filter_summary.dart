import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/providers/cards_notifier.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:provider/provider.dart';

class FilterSummary extends StatelessWidget {
  const FilterSummary({super.key});

  String _buildSummaryText(CardsNotifier cardsNotifier) {
    final filters = cardsNotifier.getAllFilters();
    final sort = cardsNotifier.getActiveSort();
    final cardCount = cardsNotifier.getFilteredCards().length;
    List<String> filterNames = [];
    for (var filter in filters) {
      filterNames.add(filter.label);
    }

    String summary = "$cardCount match${cardCount != 1 ? "es" : ""} | ";

    if (filterNames.isNotEmpty) {
      summary += "Filter: ${filterNames.join(', ')}";
    }

    if (sort.label != "Date Added") {
      summary += "${summary.isNotEmpty ? ' | ' : ''}Sort: ${sort.label}";
    }

    return summary;
  }

  void _resetFilters(CardsNotifier cardsNotifier) {
    cardsNotifier.getAllFilters().toList().forEach((filter) {
      cardsNotifier.removeFilter(filter);
    });
    cardsNotifier.resetSort();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardsNotifier>(
      builder: (context, cardsNotifier, _) {
        final hasActiveFilters = cardsNotifier.getAllFilters().isNotEmpty ||
            (cardsNotifier.getActiveSort().label != "Date Added");

        if (!hasActiveFilters) {
          return const SizedBox.shrink();
        }
        int cardCount = cardsNotifier.getFilteredCards().length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _buildSummaryText(cardsNotifier),
                      style: TextStyle(
                        color:
                            cardCount > 0 ? ThemeColors.green : ThemeColors.red,
                        fontFamily: Fonts.rubik,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Button(
                    buttonType: ButtonType.ghost,
                    onTap: () => _resetFilters(cardsNotifier),
                    icon: Icons.close_outlined,
                    labelColor: ThemeColors.red,
                    color: ThemeColors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
