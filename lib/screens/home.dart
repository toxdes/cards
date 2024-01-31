import 'package:cards/config/colors.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: ThemeColors.gray3,
        alignment: Alignment.center,
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Hello, world",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 24, color: ThemeColors.white2)),
              Container(
                margin: const EdgeInsets.all(12),
                child: const Text("one two three four five",
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 18, color: ThemeColors.white3)),
              )
            ],
          ),
        ));
  }
}
