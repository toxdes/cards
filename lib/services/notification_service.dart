import 'package:cards/services/platform_service.dart';
import 'package:cards/services/toast_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin? _notificationPlugin;

  static const String _channelId = 'cards_default';
  static const String _channelName = "Notifications for Cards";
  static const String _channelDesc = "Notifications for cards app";
  static int _notificationId = 0;

  // notification actions
  static const String _clearNotificationAction = "clear_notification";

  static Future<void> initialize() async {
    if (PlatformService.isWindows() || PlatformService.isLinux()) {
      await localNotifier.setup(appName: "cards");
    }
    _notificationPlugin = FlutterLocalNotificationsPlugin();

    // request permission for android 13+
    _notificationPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // android specific settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS and MacOS specific settings
    DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestCriticalPermission: false,
            notificationCategories: [
          DarwinNotificationCategory("cards-notification", actions: [
            DarwinNotificationAction.plain("clear", "Clear",
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.destructive
                })
          ])
        ]);

    // linux specific settings
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);

    await _notificationPlugin?.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            _onDidReceiveBackgroundNotificationResponse);
  }

  static void _clearClipboardData() {
    Clipboard.setData(const ClipboardData(text: ""));
    ToastService.show(
        message: "Card number cleared from clipboard",
        status: ToastStatus.unknown);
  }

  static Future<void> _onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) async {
    ToastService.show(
        message: "_onDidReceiveBackgroundNotificationResponse was called",
        status: ToastStatus.success);
  }

  static Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    _notificationPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.stopForegroundService();
    _clearClipboardData();
  }

  static Future<void> showNotification(
      {required String title, String? body, String? payload}) async {
    if (PlatformService.isAndroid()) {
      return await _showNotificationAndroid(title: title, body: body ?? "");
    }
    if (PlatformService.isWindows() || PlatformService.isLinux()) {
      _showNotificationWindowsOrLinux(title: title, body: body ?? "");
    }
    if (PlatformService.isDarwin()) {
      _showNotificationDarwin(title: title, body: body ?? "");
    }
  }

  static Future<void> _checkAndRequestNotificationPermsDarwin() async {
    if (PlatformService.isMacOS()) {
      NotificationsEnabledOptions? options = await _notificationPlugin
          ?.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      if (options != null && options.isAlertEnabled == true) return;
      await _notificationPlugin
          ?.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true);
      return;
    }
    if (PlatformService.isIOS()) {
      NotificationsEnabledOptions? options = await _notificationPlugin
          ?.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      if (options != null && options.isAlertEnabled == true) return;
      await _notificationPlugin
          ?.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true);
      return;
    }
  }

  static Future<void> _showNotificationDarwin(
      {required title, required body}) async {
    ++_notificationId;
    await _checkAndRequestNotificationPermsDarwin();
    if (PlatformService.isMacOS()) {
      _notificationPlugin
          ?.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.show(_notificationId, title, body);
    } else if (PlatformService.isIOS()) {
      _notificationPlugin
          ?.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.show(
            _notificationId,
            title,
            body,
          );
    }
  }

  static Future<void> _showNotificationWindowsOrLinux(
      {required String title, required String body}) async {
    LocalNotification notification = LocalNotification(
        title: title,
        body: body,
        actions: [LocalNotificationAction(text: "Clear")]);
    notification.onClickAction = (actionIndex) {
      if (actionIndex == 0) {
        _clearClipboardData();
      }
    };
    notification.onClick = () async {
      if (PlatformService.isDesktop()) {
        await windowManager.show();
        await windowManager.focus();
      }
    };
    await notification.show();
  }

  static Future<void> _showNotificationAndroid(
      {required String title,
      String body = "",
      String? payload,
      int removeAfterMs = -1}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      styleInformation: BigTextStyleInformation(body,
          htmlFormatContent: true,
          htmlFormatSummaryText: true,
          htmlFormatBigText: true),
      importance: Importance.max,
      ongoing: true,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(_clearNotificationAction, "CLEAR",
            showsUserInterface: true)
      ],
      priority: Priority.max,
      ticker: 'ticker',
      colorized: true,
    );

    /// only using foreground service can color the background
    await _notificationPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.startForegroundService(1, title, body,
            notificationDetails: androidPlatformChannelSpecifics,
            payload: payload,
            foregroundServiceTypes: {
          AndroidServiceForegroundType.foregroundServiceTypeDataSync
        });
    if (removeAfterMs != -1) {
      Future.delayed(Duration(milliseconds: removeAfterMs), () {
        _notificationPlugin
            ?.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.stopForegroundService();
        _clearClipboardData();
      });
    }
  }
}
