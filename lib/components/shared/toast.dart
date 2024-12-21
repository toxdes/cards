import 'package:cards/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();
  factory ToastManager() => _instance;
  ToastManager._internal();
  Color _backgroundColor = ThemeColors.white1;
  Color _textColor = ThemeColors.gray1;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  OverlayEntry? _overlayEntry;

  void show(
      {required String message,
      Duration duration = const Duration(seconds: 2),
      backgroundColor = ThemeColors.white1,
      textColor = ThemeColors.gray1}) {
    _backgroundColor = backgroundColor;
    _textColor = textColor;
    if (navigatorKey.currentState == null) {
      debugPrint("Navigator key is not initialized. Cannot show toast.");
      return;
    }

    _overlayEntry
        ?.remove(); // Remove any existing toast before showing a new one
    _overlayEntry = _createOverlayEntry(message, duration);
    navigatorKey.currentState!.overlay!.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(String message, Duration duration) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 50,
          left: 20,
          right: 20,
          child: Material(
            color: ThemeColors.transparent,
            child: Center(
              child: _buildToast(message, duration),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToast(String message, Duration duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: _textColor),
      ),
    )
        .animate(onComplete: (AnimationController controller) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        })
        .fadeIn(duration: 300.ms)
        .then(delay: duration)
        .fadeOut(duration: 300.ms);
  }
}
