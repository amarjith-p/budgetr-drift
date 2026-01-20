import 'package:budget/features/backup_restore/screens/backup_screen.dart';
import 'package:budget/features/database_viewer/screens/database_viewer_screen.dart';
import 'package:budget/features/qr_sync/screens/qr_generate_screen.dart';
import 'package:budget/features/qr_sync/screens/qr_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../settings/screens/settings_screen.dart';
import 'category_manager_screen.dart';

class ConfigurationMenuScreen extends StatelessWidget {
  const ConfigurationMenuScreen({super.key});

  Future<void> _handleSecureAccess(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool didAuthenticate = false;

    try {
      // Check if device supports biometrics or has a passcode set
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _showError(context,
            "Device security is not setup. Please set a Passcode/FaceID.");
        return;
      }

      // Trigger the Authentication Prompt
      didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to access Database Viewer',
        options: const AuthenticationOptions(
          biometricOnly: false, // Allows PIN/Pattern/Password as fallback
          stickyAuth: true,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        _showError(
            context, "Authentication Error: ${e.toString().split('] ').last}");
      }
      return;
    }

    if (didAuthenticate && context.mounted) {
      // Success: Navigate to the protected screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DatabaseViewerScreen()),
      );
    }
  }

  void _showError(BuildContext context, String message) {
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
    const cardColor = Color(0xFF1B263B);

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
        child: Column(
          children: [
            _buildMenuCard(
              context,
              title: "Budget Buckets",
              subtitle: "Configure your Budget Rules",
              icon: Icons.pie_chart_outline,
              color: const Color(0xFF3A86FF),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
            const SizedBox(height: 16),
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
            _buildMenuCard(
              context,
              title: "Sync & Clone",
              subtitle: "Transfer data to another device",
              icon: Icons.phonelink_ring_rounded,
              color: const Color(0xFF4CC9F0), // Cyan accent
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor:
                      Colors.transparent, // Important for glass effect
                  builder: (ctx) => Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B263B),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
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

                        // Sender Option
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A86FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.upload_rounded,
                                color: Color(0xFF3A86FF)),
                          ),
                          title: const Text("Generate QR (Sender)",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
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

                        // Receiver Option
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                              "Overwrite this device with new data",
                              style: TextStyle(color: Colors.white54)),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const QrScanScreen()));
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
              onTap: () => _handleSecureAccess(context), // <--- Protected Call
            ),
            // // NEW Notification Card
            // _buildMenuCard(
            //   context,
            //   title: "Notification Uplink",
            //   subtitle: "Manage System Alerts & Reminders",
            //   icon: Icons.notifications_active_outlined,
            //   color: const Color(0xFF4CC9F0),
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => const NotificationSettingsScreen(),
            //     ),
            //   ),
            // ),
          ],
        ),
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
}
