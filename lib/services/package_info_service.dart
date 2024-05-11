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

class PackageInfoService {
  static PackageInformation? _info;
  static Future<PackageInformation> getPackageInfo() async {
    if (_info == null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _info = PackageInformation(
          packageName: packageInfo.packageName,
          versionName: packageInfo.version,
          versionCode: packageInfo.buildNumber,
          env: kReleaseMode ? "prod" : "dev");
    }
    return _info!;
  }
}
