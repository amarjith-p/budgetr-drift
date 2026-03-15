import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:restart_app/restart_app.dart';
import 'package:dotted_border/dotted_border.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  String _statusText = "Align code within frame";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        await HapticFeedback.heavyImpact();
        _processSync(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _processSync(String rawData) async {
    setState(() {
      _isProcessing = true;
      _statusText = "Handshake established...";
    });

    try {
      final data = jsonDecode(rawData);
      if (data['type'] != 'budgetr_sync_v1') throw "Invalid QR Code";

      final String url =
          'http://${data['ip']}:${data['port']}/download?token=${data['token']}';

      setState(() => _statusText = "EXTRACTING REMOTE MATRIX...");
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200)
        throw "Sync failed (${response.statusCode})";

      setState(() => _statusText = "INITIALIZING RESTORE PROTOCOL...");
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'budgetr_local_v2.sqlite'));
      await dbFile.writeAsBytes(response.bodyBytes, flush: true);

      setState(() => _statusText = "Success! Restarting...");
      await Future.delayed(const Duration(seconds: 1));
      Restart.restartApp();
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusText = "Error: ${e.toString().split(':').last.trim()}";
      });
      // Allow retry after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isProcessing)
          setState(() => _statusText = "Align code within frame");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Layer
          MobileScanner(onDetect: _onDetect),

          // 2. Dark Overlay with Cutout
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black54,
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Scanner Frame & Animation
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                children: [
                  DottedBorder(
                    color: Colors.white.withOpacity(0.5),
                    strokeWidth: 2,
                    dashPattern: const [10, 10],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(20),
                    child: Container(),
                  ),
                  // Animated Line
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: 280 * _animationController.value,
                        left: 0,
                        right: 0,
                        // --- FIX STARTED HERE ---
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CC9F0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CC9F0).withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                        ),
                        // --- FIX ENDED HERE ---
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Top App Bar
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 5. Bottom Status
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                color: const Color(0xFF1B263B).withOpacity(0.9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isProcessing)
                      const LinearProgressIndicator(
                          color: Color(0xFF4CC9F0),
                          backgroundColor: Colors.black26),
                    if (_isProcessing) const SizedBox(height: 16),
                    Text(
                      _statusText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
