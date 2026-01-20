import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qr_sync_service.dart';

class QrGenerateScreen extends StatefulWidget {
  const QrGenerateScreen({super.key});

  @override
  State<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen>
    with SingleTickerProviderStateMixin {
  final QrSyncService _service = QrSyncService();
  String? _qrData;
  String _statusMessage = "Initializing secure link...";

  // Design Constants
  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF4CC9F0);

  @override
  void initState() {
    super.initState();
    _initServer();
  }

  Future<void> _initServer() async {
    final ip = await _service.getLocalIpAddress();
    if (ip == null) {
      if (mounted) setState(() => _statusMessage = "Connect to Wi-Fi to sync.");
      return;
    }

    await _service.startServer((log) {
      // Optional: Update UI with connection logs
    });

    if (mounted) {
      setState(() {
        _qrData = _service.getQrPayload();
        _statusMessage = "Scan this to sync the Database";
      });
    }
  }

  @override
  void dispose() {
    _service.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlurBlob(Colors.blue.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildBlurBlob(Colors.purple.withOpacity(0.2)),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlassContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Scan QR Code",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // QR Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _accentColor.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: _qrData == null
                            ? const CircularProgressIndicator(
                                color: Colors.black)
                            : QrImageView(
                                data: _qrData!,
                                version: QrVersions.auto,
                                size: 220.0,
                                backgroundColor: Colors.white,
                              ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildWarningPill(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBlob(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildWarningPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_tethering, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          const Text(
            "Both Devices must be connected on same Wi-Fi",
            style: TextStyle(color: Colors.amber, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
