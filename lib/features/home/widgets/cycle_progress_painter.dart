import 'package:flutter/material.dart';
import 'dart:math' as math;

class CycleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int avgCycle;
  final int fertileDay;
  final int ovulationDay;
  final int periodDuration;
  final double glowFactor; // 0.0 to 1.0
  final String? glowingMarker; // "fertile", "ovulation", "period", or null (handle)

  CycleProgressPainter({
    required this.progress, 
    required this.color,
    required this.avgCycle,
    required this.fertileDay,
    required this.ovulationDay,
    required this.periodDuration,
    this.glowFactor = 0.0,
    this.glowingMarker,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const double strokeWidth = 35.0;
    
    final paint = Paint()
      ..color = Colors.grey.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      paint..color = Colors.grey.withAlpha(30),
    );

    // Progress track
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      
      // Clean Single-Color Diffuse Gradient (Trail)
      // This creates a soft glow that follows the handle
      final Gradient gradient = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.2), // Very faint tail
          color.withOpacity(0.6), // Growing intensity
          color,                  // Vibrant head
          color.withOpacity(0.0), 
        ],
        stops: [
          0.0,
          progress * 0.4, 
          progress * 0.8,
          progress,       
          progress + 0.001,
        ],
        transform: const GradientRotation(-math.pi / 2),
      );

      // DIFFUSE GLOW LAYER
      final Paint glowPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10); // Contained soft blur

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );

      // SEMI-SOLID CORE LAYER (for definition)
      final Paint corePaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

       canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        corePaint,
      );
    }

    // STATIC INDICATORS (Markers)
    void drawMarker(int day, Color markerColor, String markerType) {
      final angle = -math.pi / 2 + (2 * math.pi * ((day - 1) / avgCycle));
      final offset = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      // Glow for this marker if it matches the glowingMarker type
      if (glowingMarker == markerType && glowFactor > 0) {
        HSLColor hsl = HSLColor.fromColor(markerColor);
        Color vividGlowColor = hsl.withSaturation(math.min(1.0, hsl.saturation * 1.5)).withLightness(hsl.lightness * 0.9).toColor();

        final glowPaint = Paint()
          ..color = vividGlowColor.withOpacity((1.0 - glowFactor) * 0.7) 
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 + (glowFactor * 35);
        
        canvas.drawCircle(offset, 13 + (glowFactor * 25), glowPaint);
        
        final tightGlowPaint = Paint()
          ..color = vividGlowColor.withOpacity((1.0 - glowFactor) * 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(offset, 13 + (glowFactor * 10), tightGlowPaint);
      }

      // White ring for markers
      canvas.drawCircle(
        offset, 
        13, 
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
      );
    }

    drawMarker(1, const Color(0xFFEBD8F5), "period"); // Purple (matches card)
    drawMarker(fertileDay, const Color(0xFFD4E2FF), "fertile"); // Aqua (matches card)
    drawMarker(ovulationDay, const Color(0xFFFFE5E9), "ovulation"); // Pink (matches card)

    // Handle
    final angle = -math.pi / 2 + (2 * math.pi * progress);
    final handleOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // GLOW EFFECT for Handle (only if no specific marker is glowing)
    if (glowingMarker == null && glowFactor > 0) {
      final glowPaint = Paint()
        ..color = color.withOpacity((1.0 - glowFactor) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (glowFactor * 20);
      
      canvas.drawCircle(handleOffset, 18 + (glowFactor * 15), glowPaint);
    }

    // Ball/Handle (as a White Ring)
    canvas.drawCircle(
      handleOffset, 
      18, 
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 
    );
  }

  @override
  bool shouldRepaint(covariant CycleProgressPainter oldDelegate) {
     return oldDelegate.progress != progress || 
            oldDelegate.color != color || 
            oldDelegate.glowFactor != glowFactor ||
            oldDelegate.glowingMarker != glowingMarker;
  }
}
