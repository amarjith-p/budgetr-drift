import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart'; // [NEW] Import Restart Package
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_bottom_sheet.dart';
import '../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = GetIt.I<BackupService>();
  bool _isLoading = false;
  DateTime? _lastBackupTime;

  // --- ACTIONS ---

  Future<void> _handleSaveToDevice() async {
    setState(() => _isLoading = true);
    try {
      final path = await _backupService.saveBackupToDevice();
      if (path != null && mounted) {
        setState(() => _lastBackupTime = DateTime.now());
        showStatusSheet(
          context: context,
          title: "Backup Saved",
          message:
              "Your financial data has been successfully saved to your device storage.",
          icon: Icons.check_circle_rounded,
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
        // [NEW] Automated Restart Logic
        showStatusSheet(
          context: context,
          title: "Restore Complete",
          message:
              "Data restored successfully. The app will restart in a moment to apply changes.",
          icon: Icons.check_circle_rounded,
          color: BudgetrColors.success,
          buttonText: "Restarting...",
          onDismiss:
              () {}, // No-op: preventing manual dismiss during auto-restart
        );

        // Wait 2 seconds so user sees the success message
        await Future.delayed(const Duration(seconds: 2));

        // Kill and Restart the App Process
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

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Data Management"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BudgetrColors.background.withOpacity(0.9),
                BudgetrColors.background.withOpacity(0.5)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Background Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    BudgetrColors.accent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  center: Alignment.center,
                  radius: 0.6,
                ),
              ),
            ),
          ),

          if (_isLoading)
            const Center(
                child: CircularProgressIndicator(color: BudgetrColors.accent))
          else
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 110, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 30),

                  // Section Header
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text("BACKUP",
                        style: BudgetrStyles.caption
                            .copyWith(color: BudgetrColors.accent)),
                  ),

                  // Backup Options
                  _buildActionTile(
                    icon: Icons.save_alt_rounded,
                    title: "Save to Device",
                    subtitle: "Export to your Downloads folder",
                    color: const Color(0xFF4CC9F0), // Info Cyan
                    onTap: _handleSaveToDevice,
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    icon: Icons.share_rounded,
                    title: "Share Backup",
                    subtitle: "Send via Email, Drive or WhatsApp",
                    color: const Color(0xFF7209B7), // Purple
                    onTap: _handleShare,
                  ),

                  const SizedBox(height: 30),

                  // Section Header
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text("RESTORE",
                        style: BudgetrStyles.caption
                            .copyWith(color: BudgetrColors.error)),
                  ),

                  // Restore Option
                  _buildActionTile(
                    icon: Icons.restore_page_rounded,
                    title: "Import Database",
                    subtitle: "Overwrite app data from a file",
                    color: BudgetrColors.error,
                    onTap: _handleRestore,
                    isOutline: true, // Distinct styling for dangerous action
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Budgetr Local Vault v2.0",
                      style: TextStyle(color: Colors.white24, fontSize: 12),
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
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BudgetrColors.success.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: BudgetrColors.success.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.cloud_done_rounded,
                  color: BudgetrColors.success, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("System Status",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    _lastBackupTime != null
                        ? "Last: ${DateFormat('MMM d, h:mm a').format(_lastBackupTime!)}"
                        : "No backups this session",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isOutline = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : const Color(0xFF1B263B),
        border: isOutline
            ? Border.all(color: color.withOpacity(0.5), width: 1)
            : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isOutline ? [] : BudgetrStyles.glowBoxShadow(Colors.black),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
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
                        style: TextStyle(
                          color: isOutline ? color : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isOutline
                              ? color.withOpacity(0.7)
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isOutline ? color.withOpacity(0.5) : Colors.white24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
