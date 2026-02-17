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
  bool _isRedirectMaskVisible = false;

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
    // If user turns ON security, lock immediately (optional, but safer)
    if (isEnabled && !_isLocked) {
      if (mounted) setState(() => _isLocked = true);
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
    if (BiometricService.instance.isInternalAuth) return;

    if (state == AppLifecycleState.resumed) {
      // 1. SECURITY CHECK
      if (BiometricService.instance.enabledNotifier.value) {
        if (_isLocked) _authenticate();
      }
      // 2. QUICK LAUNCH CHECK (If Security Off)
      else {
        // [FIX] Synchronous Check! No Await!
        // We read the cached value from memory.
        try {
          final settings = GetIt.I<SettingsService>();
          if (settings.cachedLaunchDailyExpense) {
            _executeRedirect();
          }
        } catch (_) {}
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // PREPARE MASK for next resume
      // If we know we are going to redirect next time, turn on mask NOW if possible
      // or just lock if security is on.
      if (BiometricService.instance.enabledNotifier.value) {
        if (!_isLocked && !_isAuthenticating) {
          setState(() => _isLocked = true);
        }
      } else {
        // If security off, but quick launch ON, we prepare mask?
        // Actually, setting mask here might show a black screen while minimizing.
        // Better to set it instantly on resume.
      }
    }
  }

  void _executeRedirect() {
    // [FIX] Set mask synchronously before async navigation starts
    setState(() => _isRedirectMaskVisible = true);

    _handleQuickLaunchRedirect().whenComplete(() {
      // Add small delay to let navigation finish painting
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _isRedirectMaskVisible = false);
      });
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !mounted) return;
    _isAuthenticating = true;
    final success = await BiometricService.instance.authenticate();
    _isAuthenticating = false;

    if (mounted) {
      if (success) {
        setState(() => _isLocked = false);
        _handleQuickLaunchRedirect();
      } else {
        if (_isLocked) _exitApp();
      }
    }
  }

  Future<void> _handleQuickLaunchRedirect() async {
    try {
      if (widget.navigatorKey == null) return;
      if (BiometricService.instance.isInternalAuth) return;

      final settings = GetIt.I<SettingsService>();
      // Use cached value if available, else await (startup case)
      final bool launchDaily = settings.cachedLaunchDailyExpense;

      if (launchDaily) {
        final nav = widget.navigatorKey!.currentState;
        if (nav != null) {
          nav.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DailyExpenseScreen()),
            (route) => false,
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

        // [FIX] Redirect Mask - Opaque color matches your theme
        if (_isRedirectMaskVisible)
          Positioned.fill(
            child: Container(color: const Color(0xff0D1B2A)),
          ),

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
