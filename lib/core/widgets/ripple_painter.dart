import 'package:flutter/material.dart';

class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;
  final double minRadius; // The radius where ripples start (button's edge)

  RipplePainter({
    required this.animation,
    required this.colors,
    required this.minRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0.0) return;

    final double width = size.width.isFinite ? size.width : 200.0;
    final double height = size.height.isFinite ? size.height : 60.0;
    final center = Offset(width / 2, height / 2);
    
    // Very compact expansion as seen in the latest reference
    final maxRadius = minRadius + 25.0; 
    const int rippleCount = 2;
    
    for (int i = 0; i < rippleCount; i++) {
        double stagger = 0.5; 
        double start = i * stagger;
        double t = (animation.value - start) / 0.5;
        
        if (t >= 0.0 && t <= 1.0) {
             final double curveT = Curves.easeOut.transform(t);
             final double radius = minRadius + (maxRadius - minRadius) * curveT;
             final double opacity = (1.0 - curveT).clamp(0.0, 1.0);
             final Color color = colors[i % colors.length];

             final paint = Paint()
              ..color = color.withAlpha((opacity * 0.3 * 255).toInt())
              ..style = PaintingStyle.stroke
              ..strokeWidth = 10.0; // Thinner but solid look

            canvas.drawCircle(center, radius, paint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return true; 
  }
}
