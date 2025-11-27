import 'package:cards/services/package_info_service.dart';
import 'package:cards/services/platform_service.dart';
import 'package:cards/services/toast_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin? _notificationPlugin;
  static PackageInformation? _packageInfo;
  static MethodChannel? _methodChannel;
  // notification actions - initialized in initialize()
  static late String _clearNotificationAction;

  static Future<void> init() async {
    // Initialize action string with correct package name for the flavor
    _packageInfo = await PackageInfoService.getPackageInfo();
    String packageName = _packageInfo!.packageName;
    _clearNotificationAction = "$packageName.action.CLEAR_CLIPBOARD";
    if (PlatformService.isAndroid()) {
      _methodChannel = MethodChannel(packageName);
    }
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
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS and MacOS specific settings
    DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings();

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

  static void _clearClipboardData() async {
    await Clipboard.setData(const ClipboardData(text: ""));
    ToastService.show(
        message: "Card number cleared from clipboard",
        status: ToastStatus.unknown);
  }

  static Future<void> _onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) async {
    if (response.payload != null &&
        response.actionId == _clearNotificationAction) {
      _clearClipboardData();
    }
  }

  static Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    if (response.actionId == _clearNotificationAction) {
      _notificationPlugin
          ?.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.stopForegroundService();
      _clearClipboardData();
    }
  }

  static Future<void> showNotification(
      {required String title, String? body, String? payload}) async {
    if (PlatformService.isAndroid()) {
      await showPersistentNotification(title: title, body: body ?? "");
    } else if (PlatformService.isDarwin()) {
      // TODO: handle notifications on macos and ios
    } else if (PlatformService.isWindows() || PlatformService.isLinux()) {
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
  }

  static Future<void> showPersistentNotification(
      {required String title,
      String body = "",
      String? payload,
      int removeAfterMs = -1}) async {
    if (PlatformService.isAndroid()) {
      // Use native method for proper action handling
      try {
        await _methodChannel!.invokeMethod('showNotificationWithAction', {
          'title': title,
          'body': body,
        });
      } catch (e) {
        ToastService.show(
            message: "couldn't create notification", status: ToastStatus.error);
      }
    } else {
      // TODO: implement persistent notifications for other platforms if the OS supports
      ToastService.show(
          message:
              "persistent notifications are not supported on ${PlatformService.getOS()}",
          status: ToastStatus.error);
    }

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
