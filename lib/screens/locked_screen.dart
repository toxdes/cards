import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/providers/auth_notifier.dart';
import 'package:cards/providers/preferences_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LockedScreen extends StatefulWidget {
  const LockedScreen({super.key});

  @override
  State<LockedScreen> createState() => _LockedScreenState();
}

class _LockedScreenState extends State<LockedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthNotifier authNotifier = context.read<AuthNotifier>();
      PreferencesNotifier prefsNotifier = context.read<PreferencesNotifier>();
      if (authNotifier.needsAuth(prefsNotifier.prefs.useDeviceAuth)) {
        authNotifier.authenticate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          const Icon(
            Icons.lock_outlined,
            color: ThemeColors.white1,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            "App is locked",
            style: TextStyle(
                fontFamily: Fonts.rubik,
                fontWeight: FontWeight.bold,
                color: ThemeColors.white1,
                decoration: TextDecoration.none,
                fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Authenticate to access your cards",
            style: TextStyle(
                fontFamily: Fonts.rubik,
                color: ThemeColors.white2,
                decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Consumer<AuthNotifier>(builder: (context, authNotifier, _) {
            return Button(
              icon: Icons.fingerprint_outlined,
              label: "Unlock",
              buttonType: ButtonType.primary,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: ThemeColors.blue,
              disabled: authNotifier.isAuthInProgress(),
              labelColor: ThemeColors.white1,
              onTap: () {
                authNotifier.authenticate();
              },
            );
          }),
        ],
      ),
    ));
  }
}
