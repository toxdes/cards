import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/material.dart';

class SelectOption {
  final String key;
  final String label;
  final String? desc;
  final bool? disabled;
  final IconData? icon;
  const SelectOption(
      {required this.key,
      required this.label,
      this.desc,
      this.disabled,
      this.icon});
}

class SelectFromOptions extends StatelessWidget {
  final List<SelectOption> options;
  final SelectOption? selectedOption;
  final Function(SelectOption selectedOption)? onSelectOption;
  final bool vertical;
  const SelectFromOptions(
      {super.key,
      required this.options,
      this.selectedOption,
      this.onSelectOption,
      this.vertical = false});

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return _buildVerticalLayout();
    }
    return _buildHorizontalLayout();
  }

  Widget _buildHorizontalLayout() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ...options.map((SelectOption option) {
            bool disabled = option.disabled != null && option.disabled == true;
            bool selected =
                selectedOption != null && selectedOption!.key == option.key;
            return GestureDetector(
                onTap: () {
                  if (onSelectOption != null && !disabled) {
                    onSelectOption!(option);
                  }
                },
                child: Container(
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
                      opacity: disabled ? 0.4 : 1,
                      child: Row(
                        children: [
                          // Checkmark/unchecked icon
                          selected
                              ? Icon(
                                  Icons.check_circle,
                                  color: ThemeColors.blue,
                                  size: 24,
                                )
                              : Icon(
                                  Icons.circle_outlined,
                                  color: ThemeColors.white3,
                                  size: 24,
                                ),
                          const SizedBox(width: 12),
                          // Optional icon provided
                          if (option.icon != null) ...[
                            Icon(
                              option.icon,
                              color: selected
                                  ? ThemeColors.blue
                                  : ThemeColors.white3,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                          ],
                          // Title and optional subtitle
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(option.label,
                                      style: TextStyle(
                                        color: selected
                                            ? ThemeColors.white1
                                            : ThemeColors.white2,
                                        fontFamily: Fonts.rubik,
                                        fontSize: 16,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  if (option.desc != null) ...[
                                    const SizedBox(height: 4),
                                    Text(option.desc!,
                                        style: const TextStyle(
                                          color: ThemeColors.white3,
                                          fontFamily: Fonts.rubik,
                                          fontSize: 12,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w400,
                                        ))
                                  ],
                                ]),
                          ),
                        ],
                      ),
                    )));
          })
        ],
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ...options.map((SelectOption option) {
              bool disabled =
                  option.disabled != null && option.disabled == true;
              bool selected =
                  selectedOption != null && selectedOption!.key == option.key;
              return GestureDetector(
                  onTap: () {
                    if (onSelectOption != null && !disabled) {
                      onSelectOption!(option);
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                          width: 140,
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              border: Border.all(
                                  color: selected
                                      ? ThemeColors.blue
                                      : ThemeColors.gray3,
                                  width: 2)),
                          child: Opacity(
                            opacity: disabled ? 0.4 : 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon
                                if (option.icon != null) ...[
                                  Icon(
                                    option.icon,
                                    color: selected
                                        ? ThemeColors.blue
                                        : ThemeColors.white3,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                // Title
                                Text(option.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: selected
                                          ? ThemeColors.white1
                                          : ThemeColors.white2,
                                      fontFamily: Fonts.rubik,
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w600,
                                    )),
                                // Subtitle
                                if (option.desc != null) ...[
                                  const SizedBox(height: 4),
                                  Text(option.desc!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: ThemeColors.white3,
                                        fontFamily: Fonts.rubik,
                                        fontSize: 11,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w400,
                                      ))
                                ],
                              ],
                            ),
                          )),
                      // Checkmark at bottom right corner
                      if (selected)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: ThemeColors.blue,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8))),
                            // padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.check,
                              color: ThemeColors.white1,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ));
            })
          ],
        ));
  }
}
