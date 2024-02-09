import 'package:cards/config/colors.dart';
import 'package:cards/screens/home.dart';
import 'package:flutter/material.dart';

const app = MaterialApp(
    home: Scaffold(
  body: Home(),
  backgroundColor: ThemeColors.gray1,
));
void main() {
  runApp(app);
}
