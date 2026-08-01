import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInformation {
  final String packageName;
  final String versionName;
  final String versionCode;
  final String env;

  PackageInformation({
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.env,
  });
}

class PackageInfoServiceErrorCodes {
  static const int calledWithoutInit = 0x101;
}

class PackageInfoServiceException implements Exception {
  final String message;
  final int errorCode;
  PackageInfoServiceException(this.errorCode, this.message);
  @override
  String toString() {
    return '[PackageInfoServiceException] Error $errorCode: $message';
  }
}

class PackageInfoService {
  static PackageInformation? _info;

  static Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _info = PackageInformation(
        packageName: packageInfo.packageName,
        versionName: packageInfo.version,
        versionCode: packageInfo.buildNumber,
        env: kReleaseMode ? "prod" : "dev");
  }

  static PackageInformation getPackageInfo() {
    if (_info == null) {
      throw PackageInfoServiceException(
          PackageInfoServiceErrorCodes.calledWithoutInit,
          "called without init()");
    }
    return _info!;
  }
}
