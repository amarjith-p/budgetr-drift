import 'dart:math' as math;
import 'package:flutter/material.dart';

class FuturisticLoader extends StatefulWidget {
  final double size;
  final Color color;
  final String? label; // [NEW] Text to show below
  final TextStyle? labelStyle; // [NEW] Custom text style

  const FuturisticLoader({
    super.key,
    this.size = 60.0,
    this.color = const Color(0xFF00B4D8),
    this.label, // [NEW]
    this.labelStyle, // [NEW]
  });

  @override
  State<FuturisticLoader> createState() => _FuturisticLoaderState();
}

class _FuturisticLoaderState extends State<FuturisticLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. The Core Loader
    final loader = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _LoaderPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );

    // 2. If no label, return just the loader (Compact Mode)
    if (widget.label == null) return loader;

    // 3. If label exists, return the Column (Layout Mode)
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        loader,
        SizedBox(height: widget.size * 0.3), // Dynamic spacing based on size
        Text(
          widget.label!,
          style: widget.labelStyle ??
              TextStyle(
                color: widget.color, // Defaults to match loader color
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoaderPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintRing = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final paintCore = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = progress * 2 * math.pi;

    // Draw Arcs
    canvas.drawArc(rect, startAngle, math.pi / 2, false, paintRing);
    canvas.drawArc(
        rect, startAngle + 2 * math.pi / 3, math.pi / 2, false, paintRing);
    canvas.drawArc(
        rect, startAngle + 4 * math.pi / 3, math.pi / 2, false, paintRing);

    // Draw Core
    final pulse = (math.sin(progress * 4 * math.pi) + 1) / 4 + 0.5;
    canvas.drawCircle(center, radius * 0.3 * pulse, paintCore);

    // Draw Scan Line
    final paintScan = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.4),
          color.withOpacity(0.0),
        ],
      ).createShader(rect);

    canvas.drawRect(
        Rect.fromLTWH(0, size.height * progress, size.width, 4), paintScan);
  }

  @override
  bool shouldRepaint(_LoaderPainter oldDelegate) => true;
}
