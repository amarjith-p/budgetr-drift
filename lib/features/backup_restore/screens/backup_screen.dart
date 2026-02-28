import 'dart:ui';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_bottom_sheet.dart';
import '../services/backup_service.dart';

// Sync Screens Imports
import '../../qr_sync/screens/qr_generate_screen.dart';
import '../../qr_sync/screens/qr_scan_screen.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = GetIt.I<BackupService>();
  bool _isLoading = false;
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadBackupStatus();
  }

  Future<void> _loadBackupStatus() async {
    final lastTime = await _backupService.getLastBackupTime();
    if (mounted && lastTime != null) {
      setState(() {
        _lastBackupTime = lastTime;
      });
    }
  }

  // ==========================================
  // UPDATED BACKUP HANDLERS
  // ==========================================

  Future<void> _handleSaveToDevice() async {
    setState(() => _isLoading = true);
    try {
      // This now instantly saves to BudGetR/Backups/{MMM yyyy}
      final path = await _backupService.saveBackupToDevice();

      if (path != null && mounted) {
        setState(() => _lastBackupTime = DateTime.now());

        // Show exactly where it was saved in the success sheet
        showStatusSheet(
          context: context,
          title: "Backup Secured",
          message: "Your financial data was safely auto-saved to:\n\n$path",
          icon: Icons.folder_special_rounded,
          color: BudgetrColors.success,
          buttonText: "Awesome",
        );
      }
    } catch (e) {
      _showError("Save failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isLoading = true);
    try {
      await _backupService.shareBackup();
      if (mounted) setState(() => _lastBackupTime = DateTime.now());
    } catch (e) {
      _showError("Share failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestore() async {
    showStatusSheet(
      context: context,
      title: "Restore Backup?",
      message:
          "This will PERMANENTLY REPLACE all current data with the selected backup file.\n\nThis action cannot be undone.",
      icon: Icons.warning_amber_rounded,
      color: BudgetrColors.error,
      buttonText: "Overwrite Data",
      cancelButtonText: "Cancel",
      onDismiss: () => _performRestore(),
      onCancel: () {},
    );
  }

  Future<void> _performRestore() async {
    setState(() => _isLoading = true);
    try {
      final success = await _backupService.restoreBackup();
      if (success && mounted) {
        showStatusSheet(
          context: context,
          title: "Restore Complete",
          message:
              "Data restored successfully. The app will restart in a moment to apply changes.",
          icon: Icons.check_circle_rounded,
          color: BudgetrColors.success,
          buttonText: "Restarting...",
          onDismiss: () {},
        );

        await Future.delayed(const Duration(seconds: 2));
        await Restart.restartApp();
      }
    } catch (e) {
      _showError("Restore failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showStatusSheet(
      context: context,
      title: "Action Failed",
      message: message,
      icon: Icons.error_outline_rounded,
      color: BudgetrColors.error,
    );
  }

  // ==========================================
  // SYNC NAVIGATION HELPERS
  // ==========================================

  void _openQrSender() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrGenerateScreen()),
    );
  }

  void _openQrScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
  }

  // ==========================================
  // UI BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      body: Stack(
        children: [
          // 1. Ambient Background
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00B4D8).withOpacity(0.15),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7209B7).withOpacity(0.1),
                ),
              ),
            ),
          ),

          // 2. Main Content (Fixed Layout, No Scroll)
          SafeArea(
            child: Column(
              children: [
                // 1. MODERN HEADER
                _buildModernHeader(),

                // 2. CONTENT AREA
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 30),
                        _buildSectionHeader(
                            "LOCAL VAULT", Icons.sd_storage_rounded),
                        const SizedBox(height: 16),
                        _buildLocalVaultSection(),
                        const SizedBox(height: 30),
                        _buildSectionHeader(
                            "DEVICE SYNC", Icons.devices_rounded),
                        const SizedBox(height: 16),
                        _buildSyncSection(),
                        const Spacer(),
                        const Center(
                          child: Text(
                            "BudGetR Data Engine by Amarjith",
                            style:
                                TextStyle(color: Colors.white24, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: FuturisticLoader(
                  size: 80,
                  label: "LOADING BACKUP ENGINE...",
                ),
              ),
            ),
        ],
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
          const Expanded(
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
                SizedBox(height: 2),
                Text(
                  "Data Backup & Restore",
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

  Widget _buildStatusCard() {
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border:
              Border(left: BorderSide(color: BudgetrColors.success, width: 4)),
          gradient: LinearGradient(
            colors: [
              BudgetrColors.success.withOpacity(0.1),
              Colors.transparent
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BudgetrColors.success.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_done_rounded,
                  color: BudgetrColors.success, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "System Status: Active",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _lastBackupTime != null
                        ? "Last: ${DateFormat('MMM d, h:mm a').format(_lastBackupTime!)}"
                        : "Ready to Backup",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00B4D8)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00B4D8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildLocalVaultSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.save_alt_rounded,
                label: "Save",
                sublabel: "To Device",
                color: const Color(0xFF4CC9F0),
                onTap: _handleSaveToDevice,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.share_rounded,
                label: "Share",
                sublabel: "Export File",
                color: const Color(0xFF7209B7),
                onTap: _handleShare,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _handleRestore,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1C2D).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.restore_page_rounded,
                      color: Colors.redAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Import Database",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Overwrite app data from a file",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.redAccent.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Transfer Data to another device connected to the same Wi-Fi network.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSyncButton(
                  title: "SENDER",
                  subtitle: "Generate QR",
                  icon: Icons.qr_code_rounded,
                  color: const Color(0xFF4361EE),
                  onTap: _openQrSender,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSyncButton(
                  title: "RECEIVER",
                  subtitle: "Scan QR",
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFFF72585),
                  onTap: _openQrScanner,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
