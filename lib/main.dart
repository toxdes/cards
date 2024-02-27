import 'package:cards/config/colors.dart';
import 'package:cards/screens/home.dart';
import 'package:cards/services/notification_service.dart';
import 'package:flutter/material.dart';

Widget app = const MaterialApp(
    home: Scaffold(
  body: Home(),
  backgroundColor: ThemeColors.gray1,
));
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(app);
}
