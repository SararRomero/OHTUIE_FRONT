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

      // Petal Rainbow Palette
      const Color colorMenstruation = Color(0xFFEBD8F5); 
      const Color colorFollicular = Color(0xFFF5F0FF);    
      const Color colorFertileWindow = Color(0xFFD4E2FF); 
      const Color colorOvulation = Color(0xFFFFE5E9);    
      const Color colorLuteal = Color(0xFFFFE0CC);       

      // Calculate base stops for phase boundaries
      final fStart = ((fertileDay - 1) / avgCycle).clamp(0.05, 0.95);
      final oStart = ((ovulationDay - 1) / avgCycle).clamp(0.05, 0.95);
      final lStart = (ovulationDay / avgCycle).clamp(0.05, 0.95);

      // Define "difuminado" spread (approx 1.5 - 2 days for smooth blend)
      const double spread = 0.025;

      // Construct Smooth Historical Gradient
      final List<Color> gradientColors = [
        colorMenstruation,   // 0.0: Solid Coral
        colorMenstruation,   // End of solid Period
        colorFertileWindow,  // Start of solid Fertile
        colorFertileWindow,  // End of solid Fertile
        colorOvulation,      // Start of solid Ovulation
        colorOvulation,      // End of solid Ovulation
        colorLuteal,         // Start of solid Luteal
        colorLuteal,         // End of solid Luteal
        colorMenstruation,   // Wrap-around transition back to initial Pink/Coral
      ];

      final List<double> stops = [
        0.0,
        (fStart - spread).clamp(0.0, 1.0),
        (fStart + spread).clamp(0.0, 1.0),
        (oStart - spread).clamp(0.0, 1.0),
        (oStart + spread).clamp(0.0, 1.0),
        (lStart - spread).clamp(0.0, 1.0),
        (lStart + spread).clamp(0.0, 1.0),
        (1.0 - (spread * 2)).clamp(0.0, 1.0), // Start blend back to Coral at the end
        1.0,                                  // Final 1.0 matches 0.0 (Coral)
      ];

      final Gradient gradient = SweepGradient(
        colors: gradientColors,
        stops: stops,
        transform: const GradientRotation(-math.pi / 2),
      );

      // SOLID PROGRESS LAYER
      final Paint progressPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      // Draw the arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // INNER CORE FOR REINFORCEMENT
      final Paint corePaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.9
        ..strokeCap = StrokeCap.round;

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

    drawMarker(1, const Color(0xFFEBD8F5), "period"); // Purple
    drawMarker(fertileDay, const Color(0xFFD4E2FF), "fertile"); // Blue
    drawMarker(ovulationDay, const Color(0xFFFFE5E9), "ovulation"); // Pink

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
