import 'package:cards/components/shared/button.dart';
import 'package:flutter/material.dart';

class IconButton extends StatefulWidget {
  const IconButton(
      {super.key,
      required this.onTap,
      required this.iconData,
      required this.color,
      this.buttonType = ButtonType.primary,
      this.disabled = false,
      required this.size});

  final IconData iconData;
  final Color color;
  final ButtonType buttonType;
  final VoidCallback onTap;
  final bool disabled;
  final double size;
  final double iconPadding = 0.36;
  final double scaleFactor = 0.92;

  @override
  State<StatefulWidget> createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton> {
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
          duration: const Duration(milliseconds: 50),
          curve: Curves.fastOutSlowIn,
          transformAlignment: Alignment.center,
          transform: _active
              ? (Matrix4.identity()
                ..scaleByDouble(widget.scaleFactor, widget.scaleFactor, 1, 1))
              : (Matrix4.identity()),
          child: Container(
              alignment: Alignment.center,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                  border: widget.buttonType == ButtonType.ghost
                      ? null
                      : Border.all(color: widget.color),
                  borderRadius: widget.buttonType == ButtonType.ghost
                      ? null
                      : BorderRadius.circular(widget.size)),
              child: Icon(widget.iconData,
                  color: widget.color,
                  size: widget.size - widget.size * widget.iconPadding)),
        ));
  }
}
