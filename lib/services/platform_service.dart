import 'dart:io';

import 'package:flutter/foundation.dart';

class PlatformService {
  static bool isDesktop() {
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  static bool isLinux() {
    return Platform.isLinux;
  }

  static bool isWindows() {
    return Platform.isWindows;
  }

  static bool isMacOS() {
    return Platform.isMacOS;
  }

  static bool isPhone() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static bool isIOS() {
    return Platform.isIOS;
  }

  static bool isWeb() {
    return kIsWeb;
  }
}
