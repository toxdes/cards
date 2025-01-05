import 'package:cards/components/shared/toast.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/screens/home.dart';
import 'package:cards/services/backup_service.dart';
import 'package:cards/services/migrations_service.dart';
import 'package:cards/services/notification_service.dart';
import 'package:cards/services/platform_service.dart';
import 'package:cards/services/sentry_service.dart';
import 'package:cards/utils/crypto/crypto_utils.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Widget app = MaterialApp(
  navigatorKey: ToastManager().navigatorKey,
  home: const Scaffold(
    body: Home(),
    backgroundColor: ThemeColors.gray1,
  ),
  navigatorObservers: [SentryService.getNavigatorObserver()],
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await CryptoUtils.init();
  await MigrationsService.runMigrations();
  // TODO: disable sentry until it can be made opt-in, also consider privacy implications
  // await SentryService.init();
  await BackupService.init();

  if (PlatformService.isDesktop()) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
        size: Size(1200, 800),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: "Cards");
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(app);
}
