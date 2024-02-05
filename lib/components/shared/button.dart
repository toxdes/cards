import 'package:cards/config/colors.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button(
      {super.key,
      required this.onTap,
      required this.text,
      this.buttonType = ButtonType.primary,
      this.disabled = false,
      this.width,
      this.height,
      this.alignment});

  final String text;
  final ButtonType buttonType;
  final VoidCallback onTap;
  final bool disabled;
  final double? width;
  final double? height;
  final Alignment? alignment;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _active = false;
  void setActive(bool newValue) {
    setState(() {
      _active = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.disabled ? () {} : widget.onTap,
        onTapDown: (TapDownDetails _) {
          setActive(true);
        },
        onTapUp: (TapUpDetails _) {
          setActive(false);
        },
        child: AnimatedContainer(
            // animated props
            duration: const Duration(milliseconds: 50),
            curve: Curves.fastOutSlowIn,
            transformAlignment: Alignment.center,
            transform: _active
                ? (Matrix4.identity()..scale(0.95, 0.95))
                : (Matrix4.identity()),
            // props
            // width: 160,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            width: widget.width,
            height: widget.height,
            alignment: widget.alignment,
            decoration: BoxDecoration(
                color: ThemeColors.blue
                    .withOpacity(widget.buttonType == ButtonType.ghost
                        ? 0
                        : widget.disabled
                            ? 0.4
                            : 1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(widget.text,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: widget.buttonType == ButtonType.ghost
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: ThemeColors.white1,
                    color: ThemeColors.white1
                        .withOpacity(widget.disabled ? 0.4 : 1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600))));
  }
}

enum ButtonType { primary, ghost }
