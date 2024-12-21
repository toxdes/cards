import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SelectOption {
  final String key;
  final String label;
  final String? desc;
  final bool? disabled;
  const SelectOption(
      {required this.key, required this.label, this.desc, this.disabled});
}

class SelectFromOptions extends StatelessWidget {
  final List<SelectOption> options;
  final SelectOption? selectedOption;
  final Function(SelectOption selectedOption)? onSelectOption;
  const SelectFromOptions(
      {super.key,
      required this.options,
      this.selectedOption,
      this.onSelectOption});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            ...options.map((SelectOption option) {
              bool disabled =
                  option.disabled != null && option.disabled == true;
              bool selected =
                  selectedOption != null && selectedOption!.key == option.key;
              return GestureDetector(
                  onTap: () {
                    if (onSelectOption != null) {
                      onSelectOption!(option);
                    }
                  },
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      margin: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(
                              color: selected
                                  ? ThemeColors.blue
                                  : ThemeColors.white3)),
                      child: Opacity(
                        opacity: disabled
                            ? 0.4
                            : selected
                                ? 1
                                : 0.8,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${option.label}${selected ? "    ✅" : ''}",
                                  style: TextStyle(
                                    color: selected
                                        ? ThemeColors.white1
                                        : ThemeColors.white2,
                                    fontFamily: Fonts.rubik,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  )),
                              const SizedBox(height: 4),
                              Text("${option.desc}",
                                  style: const TextStyle(
                                    color: ThemeColors.white2,
                                    fontFamily: Fonts.rubik,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ))
                            ]),
                      )));
            })
          ],
        ));
  }
}
