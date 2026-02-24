import 'package:budget/core/services/biometric_service.dart';
import 'package:budget/features/backup_restore/screens/backup_screen.dart';
import 'package:budget/features/database_viewer/screens/database_viewer_screen.dart';
import 'package:budget/features/notifications/screens/notification_manager_screen.dart';
import 'package:budget/features/qr_sync/screens/qr_generate_screen.dart';
import 'package:budget/features/qr_sync/screens/qr_scan_screen.dart';
// [NEW IMPORT] Recurring Dashboard
import 'package:budget/features/recurring/screens/recurring_dashboard.dart';
import 'package:budget/features/settings/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for typography
import 'package:local_auth/local_auth.dart';
import '../../settings/screens/settings_screen.dart';
import 'category_manager_screen.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/design/budgetr_colors.dart'; // Added for Glows

class ConfigurationMenuScreen extends StatefulWidget {
  const ConfigurationMenuScreen({super.key});

  @override
  State<ConfigurationMenuScreen> createState() =>
      _ConfigurationMenuScreenState();
}

class _ConfigurationMenuScreenState extends State<ConfigurationMenuScreen> {
  final SettingsService _settingsService = GetIt.I<SettingsService>();

  Future<void> _handleSecureAccess(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool didAuthenticate = false;

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _showError(
            "Device security is not setup. Please set a Passcode/FaceID.");
        return;
      }

      didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to access Database Viewer',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      if (mounted) {
        _showError("Authentication Error: ${e.toString().split('] ').last}");
      }
      return;
    }

    if (didAuthenticate && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DatabaseViewerScreen()),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0D1B2A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // [DESIGN UPGRADE] Ambient Glows
          _buildAmbientGlow(
              Alignment.topRight, BudgetrColors.accent.withOpacity(0.15)),
          _buildAmbientGlow(
              Alignment.bottomLeft, const Color(0xFF4361EE).withOpacity(0.1)),

          SafeArea(
            child: Column(
              children: [
                // 1. MODERN HEADER
                _buildModernHeader(),

                // 2. SCROLLABLE CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // SECTION: PREFERENCES
                        _buildSectionLabel("PREFERENCES"),
                        _buildStartupToggle(),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          title: "Notification Manager",
                          subtitle: "Triggers, Limits & Schedule",
                          icon: Icons.notifications_active_rounded,
                          color: const Color(0xFF00B4D8),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationManagerScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          title: "Transaction Categories",
                          subtitle: "Manage Income & Expense types",
                          icon: Icons.category_outlined,
                          color: const Color(0xFFF72585),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoryManagerScreen(),
                            ),
                          ),
                        ),
                        // [NEW] Recurring Payments Module Entry
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          title: "Recurring Transactions",
                          subtitle: "Manage subscriptions & auto-pay",
                          icon: Icons.autorenew_rounded,
                          color: const Color(0xFF4CC9F0),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RecurringDashboard(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // SECTION: SECURITY
                        _buildSectionLabel("SECURITY"),
                        _buildBiometricToggle(),

                        const SizedBox(height: 32),

                        // SECTION: DATA
                        _buildSectionLabel("DATA MANAGEMENT"),
                        _buildMenuCard(
                          context,
                          title: "Backup & Restore",
                          subtitle: "Export or Import your data",
                          icon: Icons.settings_backup_restore_rounded,
                          color: const Color.fromARGB(255, 110, 255, 14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const BackupScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          icon: Icons.table_view_rounded,
                          title: "Database Viewer",
                          subtitle: "Inspect raw SQL tables (Dev)",
                          color: const Color.fromARGB(255, 255, 187, 14),
                          onTap: () => _handleSecureAccess(context),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        label,
        style: GoogleFonts.robotoSlab(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "SETTINGS",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Configuration",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow(Alignment alignment, Color color) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: BiometricService.instance.enabledNotifier,
      builder: (context, enabled, child) {
        Future<void> onToggle(bool value) async {
          BiometricService.instance.markInternalAuth();
          try {
            bool auth = await BiometricService.instance.authenticate();
            if (auth) {
              await BiometricService.instance.setEnabled(value);
            }
          } finally {
            BiometricService.instance.unmarkInternalAuth();
          }
        }

        return _buildToggleTile(
          title: "Biometric Security",
          subtitle: enabled ? "App is Secured" : "Tap to Enable",
          icon: Icons.fingerprint,
          color: const Color(0xFF00B4D8),
          value: enabled,
          onChanged: onToggle,
        );
      },
    );
  }

  Widget _buildStartupToggle() {
    return FutureBuilder<bool>(
      future: _settingsService.getLaunchToDailyExpense(),
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? false;
        return _buildToggleTile(
          title: "Quick Launch",
          subtitle: enabled ? "Opens Daily Expense" : "Opens Home Dashboard",
          icon: Icons.rocket_rounded,
          color: const Color(0xFFFF9F1C),
          value: enabled,
          onChanged: (val) async {
            await _settingsService.setLaunchToDailyExpense(val);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.robotoSlab(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: color,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _BouncyButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
//  [HELPER] TACTILE BOUNCE EFFECT (Same as Home Screen)
// ==============================================================================
class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyButton({required this.child, required this.onTap});

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
