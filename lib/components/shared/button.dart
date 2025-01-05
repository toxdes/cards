import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button(
      {super.key,
      required this.onTap,
      required this.text,
      required this.color,
      this.textColor,
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
  final double scaleFactor = 0.90;
  final Color color;
  final Color? textColor;

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
                ? (Matrix4.identity()
                  ..scale(widget.scaleFactor, widget.scaleFactor))
                : (Matrix4.identity()),
            // props
            // width: 160,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            width: widget.width,
            height: widget.height,
            alignment: widget.alignment,
            decoration: BoxDecoration(
                color: widget.color.withValues(
                    alpha: widget.buttonType == ButtonType.ghost
                        ? 0
                        : widget.disabled
                            ? 0.4
                            : 1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(widget.text,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    decorationColor: ThemeColors.white1,
                    color: widget.buttonType == ButtonType.ghost
                        ? widget.color
                        : (widget.textColor ?? ThemeColors.white1)
                            .withValues(alpha: widget.disabled ? 0.4 : 1),
                    fontSize: 14,
                    fontFamily: Fonts.rubik,
                    fontWeight: FontWeight.w600))));
  }
}

enum ButtonType { primary, ghost }
