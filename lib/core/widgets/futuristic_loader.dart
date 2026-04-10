import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FuturisticLoader extends StatefulWidget {
  final double size;
  final Color color;
  final String? label;
  final TextStyle? labelStyle;

  const FuturisticLoader({
    super.key,
    this.size = 60.0,
    this.color = const Color(0xFF00B4D8),
    this.label,
    this.labelStyle,
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
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loader = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _IsometricStackPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );

    if (widget.label == null) return loader;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        loader,
        SizedBox(
            height:
                widget.size * 0.45), // Increased spacing for the stacked text
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final pulse = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
            return Opacity(
              opacity: 0.5 + (0.5 * pulse),
              child: Text(
                widget.label!,
                style: widget.labelStyle ??
                    TextStyle(
                      color: widget.color,
                      fontSize: 12,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _IsometricStackPainter extends CustomPainter {
  final double progress;
  final Color color;

  _IsometricStackPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Structural Layout
    final int layers = 4;
    final double spacing = size.width * 0.12;
    final double baseOffset = ((layers - 1) * spacing) / 2;

    // Shape Properties
    final double rectSize = size.width * 0.55;
    final double cornerRadius = size.width * 0.12;
    final rect =
        Rect.fromCenter(center: Offset.zero, width: rectSize, height: rectSize);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    double topLayerYOffset = 0.0;

    // Draw layers from bottom (index 0) to top (index 3)
    for (int i = 0; i < layers; i++) {
      final bounce =
          math.sin(progress * 2 * math.pi - (i * 0.8)) * (size.height * 0.08);
      final yOffset = (i * -spacing) + baseOffset + bounce;

      if (i == layers - 1) {
        topLayerYOffset = yOffset;
      }

      canvas.save();
      canvas.translate(center.dx, center.dy + yOffset);
      canvas.scale(1.0, 0.5); // Isometric Y-scaling

      final rotation = (progress * 2 * math.pi) + (i * 0.15);
      canvas.rotate(rotation);

      final layerProgress = i / (layers - 1);

      final fillPaint = Paint()
        ..color = color.withOpacity(0.02 + (0.08 * layerProgress))
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.035
        ..shader = SweepGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.4 + (0.6 * layerProgress)),
            color.withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(progress * 4 * math.pi - (i * 0.5)),
        ).createShader(rect);

      if (i == layers - 1) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.05
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.05);
        canvas.drawRRect(rrect, glowPaint);
      }

      canvas.drawRRect(rrect, strokePaint);
      canvas.restore();
    }

    // ==========================================
    // HOLOGRAPHIC "FS 360" TEXT
    // ==========================================

    final hologramPulse = (math.sin(progress * 4 * math.pi) + 1) / 2;

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: 'FS\n',
          style: GoogleFonts.orbitron(
            fontSize: size.width * 0.28,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            height: 0.9,
          ),
        ),
        TextSpan(
          text: '360',
          style: GoogleFonts.orbitron(
            fontSize: size.width * 0.17,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            height: 0.9,
          ),
        ),
      ],
      style: TextStyle(
        color: Colors.white.withOpacity(0.85 + (0.15 * hologramPulse)),
        shadows: [
          Shadow(
            color: color,
            blurRadius: size.width * 0.08 + (size.width * 0.04 * hologramPulse),
          ),
          Shadow(
            color: color.withOpacity(0.6),
            blurRadius: size.width * 0.2,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final floatHover = math.cos(progress * 2 * math.pi) * (size.height * 0.03);

    final textCenter = Offset(
      center.dx - (textPainter.width / 2),
      (center.dy + topLayerYOffset) -
          (textPainter.height) -
          (size.height * 0.02) +
          floatHover,
    );

    textPainter.paint(canvas, textCenter);
  }

  @override
  bool shouldRepaint(_IsometricStackPainter oldDelegate) => true;
}
