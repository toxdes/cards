import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.gray3,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Hello, world",
              textDirection: TextDirection.ltr,
              style: TextStyle(
                  fontSize: 24,
                  color: ThemeColors.white2,
                  fontFamily: Fonts.rubik,
                  fontWeight: FontWeight.w600)),
          Container(
            margin: const EdgeInsets.all(12),
            child: const Text("one two three 1234567890",
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 18, color: ThemeColors.white3)),
          )
        ],
      ),
    );
  }
}
