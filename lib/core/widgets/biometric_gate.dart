import 'dart:io';
import 'dart:ui';
import 'package:budget/features/daily_expense/screens/daily_expense_screen.dart';
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

  // [NEW] Privacy & Grace Period Controls
  bool _isPrivacyMaskVisible = false;
  DateTime? _lastPausedAt;
  static const int _lockGracePeriodSeconds = 3;

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
    // If user turns ON security, lock immediately
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

    final isSecurityEnabled = BiometricService.instance.enabledNotifier.value;

    if (state == AppLifecycleState.resumed) {
      // 1. HANDLE RESUME
      if (isSecurityEnabled) {
        bool shouldLock = false;

        // Check Grace Period
        if (_lastPausedAt != null) {
          final diff = DateTime.now().difference(_lastPausedAt!);
          if (diff.inSeconds >= _lockGracePeriodSeconds) {
            shouldLock = true;
          }
        }

        // Clear timestamp
        _lastPausedAt = null;

        if (shouldLock || _isLocked) {
          // Enforce Lock (if grace period expired OR already locked)
          setState(() {
            _isLocked = true;
            _isPrivacyMaskVisible = false; // Lock screen UI takes over
          });
          _authenticate();
        } else {
          // Grace Period Active: Lift privacy mask, don't lock
          setState(() {
            _isPrivacyMaskVisible = false;
          });
        }
      } else {
        // 2. SECURITY OFF - Quick Launch Check
        setState(() => _isPrivacyMaskVisible = false);
        _runQuickLaunchCheck();
      }
    } else if (state == AppLifecycleState.inactive) {
      // 3. TRANSIENT INTERRUPTION (Notification Shade, etc.)
      // ACTION: Show Privacy Blur, BUT DO NOT LOCK
      if (isSecurityEnabled && !_isLocked) {
        setState(() => _isPrivacyMaskVisible = true);
      }
    } else if (state == AppLifecycleState.paused) {
      // 4. BACKGROUNDING (Home, App Switcher)
      // ACTION: Record Time, Keep Privacy Blur
      _lastPausedAt = DateTime.now();
      if (isSecurityEnabled && !_isLocked) {
        setState(() => _isPrivacyMaskVisible = true);
      }
    }
  }

  void _runQuickLaunchCheck() {
    try {
      final settings = GetIt.I<SettingsService>();
      if (settings.cachedLaunchDailyExpense) {
        _executeRedirect();
      }
    } catch (_) {}
  }

  void _executeRedirect() {
    setState(() => _isRedirectMaskVisible = true);

    _handleQuickLaunchRedirect().whenComplete(() {
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
        // If authentication failed/cancelled, stay locked
        // User can tap "Unlock" button to retry
      }
    }
  }

  Future<void> _handleQuickLaunchRedirect() async {
    try {
      if (widget.navigatorKey == null) return;
      if (BiometricService.instance.isInternalAuth) return;

      final settings = GetIt.I<SettingsService>();
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

        // [NEW] Privacy Mask (Blur Only, No Lock UI)
        // Shows when app is Inactive (Notification shade) or Paused (App Switcher)
        // This ensures data is hidden, but user can return quickly without auth
        if (_isPrivacyMaskVisible && !_isLocked)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),

        // [EXISTING] Lock Screen (Blur + Buttons)
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
