import 'package:flutter/material.dart';
import 'dart:math' as math;

class CycleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int avgCycle;
  final int fertileDay;
  final int ovulationDay;
  final int periodDuration;

  CycleProgressPainter({
    required this.progress, 
    required this.color,
    required this.avgCycle,
    required this.fertileDay,
    required this.ovulationDay,
    required this.periodDuration,
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
      
      paint.shader = null;
      paint.color = color;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        paint,
      );
    }

    // STATIC INDICATORS (Markers)
    void drawMarker(int day, Color markerColor) {
      final angle = -math.pi / 2 + (2 * math.pi * ((day - 1) / avgCycle));
      final offset = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      final borderPaint = Paint()
        ..color = markerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(offset, 13, borderPaint);

      final innerPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(offset, 13, innerPaint);
    }

    drawMarker(1, const Color(0xFFFFADAD));
    drawMarker(fertileDay, const Color(0xFFFDFFB6));
    drawMarker(ovulationDay, const Color(0xFFFFD6A5));

    // Handle
    final angle = -math.pi / 2 + (2 * math.pi * progress);
    final handleOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    canvas.drawCircle(handleOffset, 18, Paint()..color = Colors.white..style = PaintingStyle.fill);
    
    canvas.drawCircle(
      handleOffset, 
      18, 
      Paint()
        ..color = color.withOpacity(1.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
