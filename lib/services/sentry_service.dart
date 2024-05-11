import 'package:cards/services/package_info_service.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static bool _initialized = false;
  static NavigatorObserver? _navigationObserver;

  static Future<void> init() async {
    await SentryFlutter.init((options) async {
      PackageInformation info = await PackageInfoService.getPackageInfo();
      options
        ..dsn =
            "https://55a155db5f0c6120375c23a4fc4799f8@o4507236696326144.ingest.us.sentry.io/4507236719198208"
        ..release = '${info.versionName}-${info.versionCode}'
        ..sampleRate = 0.2
        ..environment = info.env;
      _initialized = true;
    });
  }

  static Future<void> error(throwable, StackTrace stackTrace) async {
    if (_initialized) {
      await Sentry.captureException(throwable, stackTrace: stackTrace);
    }
  }

  static NavigatorObserver getNavigatorObserver() {
    _navigationObserver ??= SentryNavigatorObserver();
    return _navigationObserver!;
  }
}
