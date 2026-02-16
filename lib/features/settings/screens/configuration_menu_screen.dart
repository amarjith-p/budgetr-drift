import 'package:budget/core/services/biometric_service.dart';
import 'package:budget/features/backup_restore/screens/backup_screen.dart';
import 'package:budget/features/database_viewer/screens/database_viewer_screen.dart';
import 'package:budget/features/qr_sync/screens/qr_generate_screen.dart';
import 'package:budget/features/qr_sync/screens/qr_scan_screen.dart';
import 'package:budget/features/settings/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import '../../settings/screens/settings_screen.dart';
import 'category_manager_screen.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Configurations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Biometric Security Toggle (Matched Design)
              _buildBiometricToggle(),

              const SizedBox(height: 16),

              // 2. [NEW] Startup Screen Toggle
              _buildStartupToggle(),

              const SizedBox(height: 16),

              // 2. Transaction Categories
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
              const SizedBox(height: 16),

              // 3. Backup & Restore
              _buildMenuCard(
                context,
                title: "Backup & Restore",
                subtitle: "Export or Import your data",
                icon: Icons.settings_backup_restore_rounded,
                color: const Color.fromARGB(255, 110, 255, 14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BackupScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 4. Sync & Clone
              _buildMenuCard(
                context,
                title: "Sync & Clone",
                subtitle: "Transfer data to another device",
                icon: Icons.phonelink_ring_rounded,
                color: const Color(0xFF4CC9F0),
                onTap: () => _showSyncModal(context),
              ),
              const SizedBox(height: 16),

              // 5. Database Viewer (Protected)
              _buildMenuCard(
                context,
                icon: Icons.table_view_rounded,
                title: "Database Viewer",
                subtitle: "Inspect raw SQL tables (Dev)",
                color: const Color.fromARGB(255, 255, 187, 14),
                onTap: () => _handleSecureAccess(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildBiometricToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: BiometricService.instance.enabledNotifier,
      builder: (context, enabled, child) {
        Future<void> onToggle(bool value) async {
          // [NEW] Mark as internal so BiometricGate ignores the pause/resume
          BiometricService.instance.markInternalAuth();

          try {
            bool auth = await BiometricService.instance.authenticate();
            if (auth) {
              await BiometricService.instance.setEnabled(value);
            }
          } finally {
            // [NEW] Unmark after operation completes
            BiometricService.instance.unmarkInternalAuth();
          }
        }

        return GestureDetector(
          onTap: () => onToggle(!enabled),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B).withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B4D8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fingerprint,
                      color: Color(0xFF00B4D8), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Biometric Security",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enabled ? "App is Secured" : "Tap to Enable",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  activeColor: const Color(0xFF00B4D8),
                  onChanged: onToggle,
                ),
              ],
            ),
          ),
        );
      },
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Sync Device",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A86FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.upload_rounded, color: Color(0xFF3A86FF)),
              ),
              title: const Text("Generate QR (Sender)",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text("Generate QR code to send data",
                  style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const QrGenerateScreen()));
              },
            ),
            const Divider(color: Colors.white10, height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF72585).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.download_rounded,
                    color: Color(0xFFF72585)),
              ),
              title: const Text("Scan QR (Receiver)",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text("Overwrite this device with new data",
                  style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const QrScanScreen()));
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- [NEW] Startup Toggle Widget ---
  Widget _buildStartupToggle() {
    return FutureBuilder<bool>(
      future: _settingsService.getLaunchToDailyExpense(),
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? false;

        return GestureDetector(
          onTap: () async {
            await _settingsService.setLaunchToDailyExpense(!enabled);
            setState(() {}); // Refresh UI
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B).withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F1C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Color(0xFFFF9F1C), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quick Launch",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enabled
                            ? "Opens Daily Expense"
                            : "Opens Home Dashboard",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  activeColor: const Color(0xFFFF9F1C),
                  onChanged: (val) async {
                    await _settingsService.setLaunchToDailyExpense(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
