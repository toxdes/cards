import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Spinner extends StatelessWidget {
  final Color color;
  final double size;
  const Spinner({super.key, required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    List<Duration> delays = <Duration>[
      const Duration(milliseconds: 000),
      const Duration(milliseconds: 100),
      const Duration(milliseconds: 300)
    ];
    Duration interval = const Duration(milliseconds: 1000);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...delays.map((delay) {
          return Container(
            margin: const EdgeInsets.only(left: 8),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size),
            ),
          )
              .animate(
                  onPlay: (controller) {},
                  onComplete: (controller) {
                    controller.loop(period: 1800.ms);
                  })
              .scaleXY(
                  duration: interval,
                  delay: delay,
                  curve: Curves.easeInExpo,
                  begin: 1,
                  end: 1.3)
              .scaleXY(
                  duration: interval,
                  delay: delay,
                  curve: Curves.easeOutExpo,
                  begin: 1.3,
                  end: 1);
        })
      ],
    );
  }
}
