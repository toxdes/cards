import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BottomSheet extends StatefulWidget {
  const BottomSheet(
      {super.key,
      required this.isVisible,
      required this.onClose,
      this.child,
      this.title,
      this.closeLabel,
      this.heightFactor = 1.0});
  final bool isVisible;
  final VoidCallback onClose;
  final String? title;
  final String? closeLabel;
  final double heightFactor;

  final Widget? child;

  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: 240.ms, vsync: this);
  }

  @override
  void didUpdateWidget(BottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.forward(from: 0.0);
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      maintainState: true,
      maintainAnimation: true,
      child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(children: [
              Positioned.fill(
                  child: Container(
                decoration: BoxDecoration(
                    color: ThemeColors.gray1.withValues(alpha: 0.94)),
                padding: const EdgeInsets.only(top: 60),
                child: FractionallySizedBox(
                    heightFactor: widget.heightFactor,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                          color: ThemeColors.gray1,
                          border: Border(
                              top: BorderSide(
                                  width: 2,
                                  color:
                                      ThemeColors.blue.withValues(alpha: 0.8))),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24))),
                      margin: const EdgeInsets.only(top: 0),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 24, left: 32, right: 32),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  widget.title != null
                                      ? Text(widget.title!,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: Fonts.rubik,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeColors.white2))
                                      : const SizedBox.shrink(),
                                  Button(
                                    color: ThemeColors.red,
                                    label: widget.closeLabel ?? "Close",
                                    onTap: widget.onClose,
                                    buttonType: ButtonType.ghost,
                                  )
                                ]),
                            widget.child ?? SizedBox.shrink(),
                          ]),
                        ),
                      ),
                    )),
              )),
            ])),
      ).animate(autoPlay: false, controller: _animationController).slideY(
          duration: 240.ms, curve: Curves.easeOutExpo, begin: 1, end: 0),
    );
  }
}
