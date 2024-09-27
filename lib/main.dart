import 'package:cards/config/colors.dart';
import 'package:cards/screens/home.dart';
import 'package:cards/services/backup_service.dart';
import 'package:cards/services/migrations_service.dart';
import 'package:cards/services/notification_service.dart';
import 'package:cards/services/sentry_service.dart';
import 'package:cards/utils/crypto/crypto_utils.dart';
import 'package:flutter/material.dart';

Widget app = MaterialApp(
  home: const Scaffold(
    body: Home(),
    backgroundColor: ThemeColors.gray1,
  ),
  navigatorObservers: [SentryService.getNavigatorObserver()],
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await CryptoUtils.init();
  await MigrationsService.runMigrations();
  // TODO: disable sentry until it can be made opt-in, also consider privacy implications
  // await SentryService.init();
  await BackupService.init();
  runApp(app);
}
