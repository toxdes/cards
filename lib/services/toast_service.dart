import 'package:cards/components/shared/toast.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/services/platform_service.dart';
import 'package:fluttertoast/fluttertoast.dart' as ft;

enum ToastStatus { success, info, error, warning, unknown }

enum ToastDuration { short, long }

class ToastService {
  static String _getStatusIcon(ToastStatus status) {
    switch (status) {
      case ToastStatus.success:
        return "✅";
      case ToastStatus.error:
        return "❌";
      case ToastStatus.warning:
        return "⚠️";
      case ToastStatus.info:
        return "";
      case ToastStatus.unknown:
        return '';
    }
  }

  static void show(
      {required String message,
      required ToastStatus status,
      ToastDuration duration = ToastDuration.long}) {
    if (PlatformService.isPhone() || PlatformService.isWeb()) {
      ft.Fluttertoast.showToast(
        msg: "${_getStatusIcon(status)} $message",
        toastLength: duration == ToastDuration.short
            ? ft.Toast.LENGTH_SHORT
            : ft.Toast.LENGTH_LONG,
        gravity: ft.ToastGravity.BOTTOM,
        backgroundColor: ThemeColors.white2,
        textColor: ThemeColors.gray2,
      );
    } else {
      ToastManager().show(
          message: "${_getStatusIcon(status)} $message",
          duration: Duration(
              milliseconds: duration == ToastDuration.long ? 2000 : 1000),
          backgroundColor: ThemeColors.white1,
          textColor: ThemeColors.gray2);
    }
  }

  static void todo() {
    show(
      message: "Not implemented yet",
      status: ToastStatus.error,
    );
  }
}
