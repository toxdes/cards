import 'package:cards/config/colors.dart';
import 'package:cards/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  FlutterLocalNotificationsPlugin? _notificationPlugin;

  static const String _channelId = 'cards_default';
  static const String _channelName = "Notifications for Cards";
  static const String _channelDesc = "Notifications for cards app";
  int _notificationId = 1;

  // notification actions
  static const String _clearNotificationAction = "clear_notification";

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> initialize() async {
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
            onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

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

  void _clearClipboardData() {
    Clipboard.setData(const ClipboardData(text: ""));
    ToastService.show(
        message: "Card number cleared from clipboard",
        status: ToastStatus.unknown);
  }

  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  static Future<void> _onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) async {
    if (response.payload != null) {}
  }

  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    _notificationPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.stopForegroundService();
    _clearClipboardData();
  }

  Future<void> showNotification(
      {required String title, String? body, String? payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(_channelId, _channelName,
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true,
            autoCancel: false,
            color: ThemeColors.blue,
            channelDescription: _channelDesc,
            visibility: NotificationVisibility.private);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _notificationPlugin?.show(
        _notificationId, title, body, notificationDetails,
        payload: payload);
    ++_notificationId;
  }

  Future<void> showPersistentNotification(
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
        ?.startForegroundService(_notificationId, title, body,
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
    _notificationId;
  }
}
