import 'package:cards/config/colors.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button(
      {super.key, required this.onTap, required this.text, buttonType});

  final String text;
  final ButtonType buttonType = ButtonType.primary;
  final VoidCallback onTap;

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
        onTap: widget.onTap,
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
            decoration: BoxDecoration(
                color: ThemeColors.blue,
                borderRadius: BorderRadius.circular(8)),
            child: Text(widget.text,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: ThemeColors.white1,
                    fontSize: 14,
                    fontWeight: FontWeight.w600))));
  }
}

enum ButtonType { primary }
