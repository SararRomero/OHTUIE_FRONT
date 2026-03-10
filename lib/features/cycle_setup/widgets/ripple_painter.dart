import 'package:flutter/material.dart';

class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  RipplePainter({required this.animation, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    const int rippleCount = 2;
    
    for (int i = 0; i < rippleCount; i++) {
        double stagger = 0.35; 
        double start = i * stagger;
        double t = (animation.value - start) / 0.65;
        
        if (t >= 0.0 && t <= 1.0) {
             final double radius = 35 + (maxRadius - 35) * t;
             final double opacity = (1.0 - t).clamp(0.0, 1.0);
             final Color color = colors[i % colors.length];

             final paint = Paint()
              ..color = color.withAlpha((opacity * 0.6 * 255).toInt())
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4 + (4 * (1.0 - t)); 

            canvas.drawCircle(center, radius, paint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return true; 
  }
}
