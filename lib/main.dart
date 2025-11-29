import 'package:cards/components/shared/spinner.dart';
import 'package:cards/components/shared/toast.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/providers/auth_notifier.dart';
import 'package:cards/providers/cards_notifier.dart';
import 'package:cards/providers/preferences_notifier.dart';
import 'package:cards/screens/home.dart';
import 'package:cards/screens/locked_screen.dart';
import 'package:cards/services/auth_service.dart';
import 'package:cards/services/backup_service.dart';
import 'package:cards/services/migrations_service.dart';
import 'package:cards/services/notification_service.dart';
import 'package:cards/services/platform_service.dart';
import 'package:cards/services/sentry_service.dart';
import 'package:cards/utils/crypto/crypto_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Widget app = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CardsNotifier()),
    ChangeNotifierProvider(create: (_) => PreferencesNotifier()),
    ChangeNotifierProvider(create: (_) => AuthNotifier()),
  ],
  child: MaterialApp(
    navigatorKey: ToastManager().navigatorKey,
    home: Scaffold(
        body: Consumer2<AuthNotifier, PreferencesNotifier>(
          builder: (context, authNotifier, prefsNotifier, _) {
            if (!prefsNotifier.isLoaded) {
              return Center(
                  child: Spinner(color: ThemeColors.white2, size: 14));
            }
            if (authNotifier.needsAuth(prefsNotifier.prefs.useDeviceAuth)) {
              return const LockedScreen();
            }
            return const Home();
          },
        ),
        backgroundColor: ThemeColors.gray1),
    navigatorObservers: [SentryService.getNavigatorObserver()],
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: refactor this so there is no "implicit" order betweeen services, if possible
  await AuthService.init();
  await NotificationService.init();
  await CryptoUtils.init();
  await MigrationsService.runMigrations();
  // TODO: enable sentry after security hardening
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
