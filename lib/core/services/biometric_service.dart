import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
// import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  static BiometricService get instance => _instance;
  BiometricService._internal() {
    _init();
  }

  final LocalAuthentication _auth = LocalAuthentication();
  static const String _prefKey = 'is_biometric_enabled';

  final ValueNotifier<bool> enabledNotifier = ValueNotifier<bool>(false);

  // [NEW] Flag to track internal authentication events
  bool _isInternalAuth = false;
  bool get isInternalAuth => _isInternalAuth;

  void markInternalAuth() {
    _isInternalAuth = true;
  }

  void unmarkInternalAuth() {
    // Small delay ensures the lifecycle event 'resumed' is ignored
    // before we clear the flag.
    Future.delayed(const Duration(milliseconds: 500), () {
      _isInternalAuth = false;
    });
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    enabledNotifier.value = prefs.getBool(_prefKey) ?? false;
  }

  Future<bool> get isEnabled async {
    return enabledNotifier.value;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    enabledNotifier.value = value;
  }

  Future<bool> authenticate({bool allowPin = true}) async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock BudGetR to access your finances',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: !allowPin,
          useErrorDialogs: true,
        ),
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Unlock BudGetR',
            cancelButton: 'Cancel',
          ),
          // IOSAuthMessages(
          //   cancelButton: 'Cancel',
          // ),
        ],
      );
    } on PlatformException catch (e) {
      debugPrint("Auth Error: $e");
      return false;
    }
  }
}
