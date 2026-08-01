import 'package:cards/components/preferences/menu_item.dart';
import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/icon_button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/services/flavor_service.dart';
import 'package:cards/services/package_info_service.dart';
import 'package:cards/services/url_service.dart';
import 'package:flutter/material.dart' hide IconButton;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PackageInformation packageInfo = PackageInfoService.getPackageInfo();
    String flavor = FlavorService.getFlavor().getLabel();
    String versionString =
        '${packageInfo.versionName}_${packageInfo.versionCode}';
    if (flavor.isNotEmpty) {
      versionString = '$versionString - $flavor';
    }
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: ThemeColors.gray1),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                              size: 28,
                              color: ThemeColors.white2,
                              iconData: Icons.arrow_back_rounded,
                              buttonType: ButtonType.ghost,
                              onTap: () {
                                Navigator.pop(context);
                              }),
                        ),
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: const Text(
                            "About",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                fontFamily: Fonts.rubik,
                                fontWeight: FontWeight.w600,
                                color: ThemeColors.white2,
                                fontSize: 18),
                          ),
                        ))
                      ],
                    )),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      MenuItem(
                        title: "App Version",
                        icon: Icons.info_outlined,
                        hideRightIcon: true,
                        desc: versionString,
                        onTap: () {},
                      ),
                      MenuItem(
                          title: "Feedback",
                          icon:Icons.feedback_outlined,
                          desc: "Request Features and Report Bugs", 
                          onTap: () {
                            UrlService.openUrl(URLRepo.feedback);
                          }),
                      MenuItem(
                          title: "Source Code",
                          icon: Icons.code,
                          desc: "View Source Code on GitHub",
                          onTap: () {
                            UrlService.openUrl(URLRepo.sourceCode);
                          }),
                      MenuItem(
                          title: "Privacy",
                          desc: "View privacy policy", 
                          icon: Icons.privacy_tip_outlined,
                          onTap: () {
                            UrlService.openUrl(URLRepo.privacyPolicy);
                          }),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
