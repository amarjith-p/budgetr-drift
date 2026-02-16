import 'dart:io';
import 'dart:ui';
import 'package:budget/features/daily_expense/screens/daily_expense_screen.dart';
import 'package:budget/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import '../services/biometric_service.dart';
import '../../features/settings/services/settings_service.dart';

class BiometricGate extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const BiometricGate({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    BiometricService.instance.enabledNotifier
        .addListener(_onSecuritySettingChanged);
    _checkInitialStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BiometricService.instance.enabledNotifier
        .removeListener(_onSecuritySettingChanged);
    super.dispose();
  }

  void _onSecuritySettingChanged() {
    final isEnabled = BiometricService.instance.enabledNotifier.value;
    if (!isEnabled && _isLocked) {
      if (mounted) setState(() => _isLocked = false);
    }
  }

  Future<void> _checkInitialStatus() async {
    if (BiometricService.instance.enabledNotifier.value) {
      setState(() => _isLocked = true);
      await Future.delayed(const Duration(milliseconds: 300));
      _authenticate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // [CRITICAL CHECK]
    // If we are doing an Internal Auth (like toggling settings), ignore lifecycle completely.
    if (BiometricService.instance.isInternalAuth) return;

    // 1. Handle Locking (If Security Enabled)
    if (BiometricService.instance.enabledNotifier.value) {
      if (!_isAuthenticating) {
        if (state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) {
          if (!_isLocked) {
            setState(() => _isLocked = true);
          }
        } else if (state == AppLifecycleState.resumed && _isLocked) {
          _authenticate();
        }
      }
    }

    // 2. Handle "Quick Launch" Redirect (If Security Disabled)
    // We only want to do this if coming from a REAL background state, not a dialog.
    if (state == AppLifecycleState.resumed &&
        !BiometricService.instance.enabledNotifier.value) {
      _handleQuickLaunchRedirect();
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !mounted) return;

    _isAuthenticating = true;

    final success = await BiometricService.instance.authenticate();

    _isAuthenticating = false;

    if (mounted) {
      if (success) {
        setState(() => _isLocked = false);
        // Security Success -> Now Redirect
        _handleQuickLaunchRedirect();
      } else {
        if (_isLocked) _exitApp();
      }
    }
  }

  Future<void> _handleQuickLaunchRedirect() async {
    try {
      if (widget.navigatorKey == null) return;

      // Double check internal auth just to be safe
      if (BiometricService.instance.isInternalAuth) return;

      final settings = GetIt.I<SettingsService>();
      final bool launchDaily = await settings.getLaunchToDailyExpense();

      if (launchDaily) {
        final nav = widget.navigatorKey!.currentState;
        if (nav != null) {
          nav.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
          nav.push(
            MaterialPageRoute(builder: (_) => const DailyExpenseScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint("Quick Launch Redirect Error: $e");
    }
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline_rounded,
                          size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "BudGetR Locked",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        inherit: false,
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: _authenticate,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text("Unlock"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
