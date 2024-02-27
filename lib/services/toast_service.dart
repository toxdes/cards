import 'package:cards/config/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastStatus { success, info, error, warning }

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
        return "🛈";
      default:
        return '';
    }
  }

  static void show(
      {required String message,
      required ToastStatus status,
      ToastDuration duration = ToastDuration.long}) {
    Fluttertoast.showToast(
      msg: "${_getStatusIcon(status)} $message",
      toastLength: duration == ToastDuration.short
          ? Toast.LENGTH_SHORT
          : Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: ThemeColors.white2,
      textColor: ThemeColors.gray2,
    );
  }
}
