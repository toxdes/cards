import 'package:cards/config/colors.dart';
import 'package:cards/screens/home.dart';
import 'package:flutter/material.dart';

Widget app = const MaterialApp(
    home: Scaffold(
  body: Home(),
  backgroundColor: ThemeColors.gray1,
));
void main() {
  runApp(app);
}
