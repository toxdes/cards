import 'package:cards/services/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlRepo {
  static const String privacyPolicy = "https://cards.toxdes.com/privacy-policy";
  static const String feedback = "https://cardsapp.featurebase.app";
  static const String support = "https://toxdes.com/support";
  static const String sourceCode = "https://github.com/toxdes/cards";
}

class UrlService {
  static Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ToastService.show(
          message: "Couldn't open URL: $url", status: ToastStatus.error);
      return false;
    }
  }
}
