import 'package:flutter/material.dart';
import 'dart:math';

class OvulationFlowerPainter extends CustomPainter {
  final Color color;
  OvulationFlowerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final petalRadius = size.width / 2.5; 
    final centerOffset = size.width / 4;

    // Draw 5 petals for a more "true floral" look (User requested to keep it at 5)
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * pi / 5 - pi / 2; // Start from top
      final petalCenter = Offset(
        center.dx + centerOffset * cos(angle),
        center.dy + centerOffset * sin(angle),
      );
      canvas.drawCircle(petalCenter, petalRadius, paint);
    }
    
    // Fill the middle completely with a slightly larger center
    canvas.drawCircle(center, petalRadius * 1.4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
