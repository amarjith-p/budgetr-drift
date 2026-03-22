import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/modern_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/futuristic_loader.dart';
import '../services/factory_reset_service.dart';

class FactoryResetScreen extends StatefulWidget {
  const FactoryResetScreen({Key? key}) : super(key: key);

  @override
  State<FactoryResetScreen> createState() => _FactoryResetScreenState();
}

class _FactoryResetScreenState extends State<FactoryResetScreen> {
  late final FactoryResetService _resetService;
  final TextEditingController _securityController = TextEditingController();

  bool _isLoading = true;
  bool _isProcessing = false;
  String _processingMessage = "";
  String _backupFileName = "Loading...";

  @override
  void initState() {
    super.initState();
    _resetService = FactoryResetService(GetIt.I<AppDatabase>());
    _initializeData();
  }

  Future<void> _initializeData() async {
    final fileName = await _resetService.getDynamicBackupFileName();
    if (mounted) {
      setState(() {
        _backupFileName = fileName;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _securityController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =====================================================================
  // STEP 1: BACKUP HANDLERS
  // =====================================================================

  Future<void> _handleSaveAction() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = "SAVING BACKUP...";
    });

    try {
      final savedPath = await _resetService.saveBackupToDevice(_backupFileName);
      setState(() => _isProcessing = false);

      _showFinalNukeDialog(
        title: "Backup Saved Successfully",
        message:
            "Your file was saved to:\n$savedPath\n\nAre you absolutely sure you are ready to permanently wipe all app data?",
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      _showNotification(e.toString(), isError: true);
    }
  }

  Future<void> _handleShareAction() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = "PREPARING SHARE DIALOG...";
    });

    try {
      await _resetService.exportBackupViaShare(_backupFileName);

      setState(() => _isProcessing = false);
      _showFinalNukeDialog(
        title: "Share Completed",
        message:
            "Did you successfully save or send your backup file to a safe location?\n\nIf yes, are you ready to permanently wipe all app data?",
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      _showNotification(e.toString(), isError: true);
    }
  }

  void _handleSkipBackupAction() {
    _showFinalNukeDialog(
      title: "WARNING: Skipping Backup",
      message:
          "You have chosen NOT to save a backup. All accounts, transactions, and settings will be lost forever.\n\nProceed with Factory Reset?",
      isDanger: true,
    );
  }

  // =====================================================================
  // STEP 2: THE FINAL CHECKPOINT & THE "FUTURISTIC WIPE" EXECUTION
  // =====================================================================

  void _showFinalNukeDialog(
      {required String title, required String message, bool isDanger = false}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white10)),
            title: Row(
              children: [
                Icon(
                    isDanger
                        ? Icons.gpp_bad_rounded
                        : Icons.check_circle_rounded,
                    color: isDanger ? Colors.redAccent : Colors.green),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17))),
              ],
            ),
            content: Text(message,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.5)),
            actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("CANCEL",
                    style: TextStyle(
                        color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _executeWipe();
                },
                child: const Text("YES, WIPE DATA",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
  }

  /// The futuristic, multi-stage loading sequence to mask screen freezing
  Future<void> _executeWipe() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = "INITIATING FACTORY WIPE...";
    });

    try {
      // Stage 1: Loader spins freely
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) setState(() => _processingMessage = "ERASING CORE DATA...");

      // Stage 2: Simulating deep deletion
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) setState(() => _processingMessage = "REBOOTING SYSTEM...");

      // Stage 3: Tiny pause before the actual platform restart occurs
      await Future.delayed(const Duration(milliseconds: 500));

      // Execute the actual physical wipe and restart
      await _resetService.executeFactoryWipe();
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      _showNotification("Reset Failed: $e", isError: true);
    }
  }

  // =====================================================================
  // UI BUILDER
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    final bool canProceed =
        _securityController.text.trim().toUpperCase() == "RESET";

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.redAccent.withOpacity(0.15),
                      blurRadius: 100,
                      spreadRadius: 50)
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const ModernAppBar(
                  title: "Factory Reset",
                  subtitle: "System Data Management",
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child:
                              FuturisticLoader()) // INITIAL LOAD STATE NOW USES FUTURISTIC LOADER
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          children: [
                            GlassCard(
                              color: Colors.redAccent.withOpacity(0.05),
                              borderRadius: 20,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const Icon(Icons.warning_rounded,
                                      color: Colors.redAccent, size: 48),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "DANGER ZONE",
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "You are about to completely wipe FinStack 360. All accounts, expenses, categories, and settings will be permanently destroyed. The app will restart in a Day 1 Factory condition.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            GlassCard(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: 16,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.save_rounded,
                                          color: Colors.blueAccent, size: 18),
                                      SizedBox(width: 8),
                                      Text("BACKUP PREPARED",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 1)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_backupFileName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Center(
                              child: Text(
                                "Type RESET to unlock actions",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: canProceed
                                        ? Colors.redAccent
                                        : Colors.white10),
                              ),
                              child: TextField(
                                controller: _securityController,
                                onChanged: (val) => setState(() {}),
                                style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    letterSpacing: 4),
                                textAlign: TextAlign.center,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: "R E S E T",
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.1),
                                      letterSpacing: 4),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: canProceed ? 1.0 : 0.4,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildActionButton(
                                          title: "Save to Device",
                                          icon: Icons.download_rounded,
                                          color: Colors.green,
                                          onTap: canProceed
                                              ? _handleSaveAction
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildActionButton(
                                          title: "Share File",
                                          icon: Icons.ios_share_rounded,
                                          color: Colors.blueAccent,
                                          onTap: canProceed
                                              ? _handleShareAction
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: canProceed
                                                ? Colors.redAccent
                                                    .withOpacity(0.5)
                                                : Colors.transparent),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                      ),
                                      icon: Icon(Icons.delete_forever_rounded,
                                          color: canProceed
                                              ? Colors.redAccent
                                              : Colors.white24),
                                      label: Text("Skip Backup & Force Reset",
                                          style: TextStyle(
                                              color: canProceed
                                                  ? Colors.redAccent
                                                  : Colors.white24,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: canProceed
                                          ? _handleSkipBackupAction
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // The Futuristic Full Screen Overlay (WIPING / SAVING / SHARING STATE)
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.90),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FuturisticLoader(), // OVERLAY LOAD STATE NOW USES FUTURISTIC LOADER
                    const SizedBox(height: 32),
                    Text(
                      _processingMessage,
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback? onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(onTap != null ? 0.2 : 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(onTap != null ? 0.5 : 0.1)),
        ),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
