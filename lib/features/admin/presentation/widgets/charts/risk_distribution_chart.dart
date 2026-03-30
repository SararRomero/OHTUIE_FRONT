import 'package:flutter/material.dart';
import 'dart:math' as math;

class RiskDistributionChart extends StatefulWidget {
  final Map<String, dynamic>? riskData;

  const RiskDistributionChart({super.key, required this.riskData});

  @override
  State<RiskDistributionChart> createState() => _RiskDistributionChartState();
}

class _RiskDistributionChartState extends State<RiskDistributionChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _targetRatio = 0.0;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1500),
    );

    _calculateRatio();

    _animation = Tween<double>(begin: 0.0, end: _targetRatio).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(RiskDistributionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.riskData != oldWidget.riskData) {
       _calculateRatio();
       _animateTo(_targetRatio, Curves.elasticOut);
    }
  }

  void _calculateRatio() {
    final dataMap = widget.riskData ?? {};
    final pass = (dataMap['Pass'] is num ? dataMap['Pass'] as num : 0).toDouble();
    final user = (dataMap['User'] is num ? dataMap['User'] as num : 0).toDouble();
    final token = (dataMap['Token'] is num ? dataMap['Token'] as num : 0).toDouble();
    final total = pass + user + token;
    
    // When no data -> needle to the far left.
    // When data exists -> needle to the middle (0.5), as requested.
    if (_selectedIndex == null) {
      if (total > 0) {
        _targetRatio = 0.5;
      } else {
        _targetRatio = 0.0;
      }
    }
  }

  void _animateTo(double target, Curve curve) {
    _animation = Tween<double>(begin: _animation.value, end: target).animate(
      CurvedAnimation(parent: _controller, curve: curve)
    );
    _controller.forward(from: 0.0);
  }

  void _onSegmentTapped(int index) {
      final dataMap = widget.riskData ?? {};
      final pass = (dataMap['Pass'] is num ? dataMap['Pass'] as num : 0).toDouble();
      final user = (dataMap['User'] is num ? dataMap['User'] as num : 0).toDouble();
      final token = (dataMap['Token'] is num ? dataMap['Token'] as num : 0).toDouble();
      final total = pass + user + token;

      if (total == 0) return; // Do not interact if empty

      setState(() {
         // Reset if same is tapped
         if (_selectedIndex == index) {
            _selectedIndex = null;
            _targetRatio = 0.5;
            _animateTo(_targetRatio, Curves.elasticOut);
            return;
         }
         
         _selectedIndex = index;
         // 3 segments: 0 -> Left, 1 -> Center, 2 -> Right
         if (index == 0) {
           _targetRatio = 1 / 6;
         } else if (index == 1) {
           _targetRatio = 3 / 6;
         } else if (index == 2) {
           _targetRatio = 5 / 6;
         }
         
         _animateTo(_targetRatio, Curves.easeOutBack);
      });
  }

  void _onChartTapped(TapUpDetails details, Size size) {
      final dataMap = widget.riskData ?? {};
      final pass = (dataMap['Pass'] is num ? dataMap['Pass'] as num : 0).toDouble();
      final user = (dataMap['User'] is num ? dataMap['User'] as num : 0).toDouble();
      final token = (dataMap['Token'] is num ? dataMap['Token'] as num : 0).toDouble();
      final total = pass + user + token;
      
      if (total == 0) return;

      final center = Offset(size.width / 2, size.height - 20); 
      final dx = details.localPosition.dx - center.dx;
      final dy = details.localPosition.dy - center.dy;
      // In atan2, top half is -pi to 0.
      final angle = math.atan2(dy, dx);
      if (angle < 0) {
          // map -pi (left) ... 0 (right) to ratio 0.0 ... 1.0
          final ratio = (angle + math.pi) / math.pi;
          if (ratio < 0.33) {
            _onSegmentTapped(0);
          } else if (ratio < 0.66) {
            _onSegmentTapped(1);
          } else {
            _onSegmentTapped(2);
          }
      } else {
          // Tap below baseline resets
          if (_selectedIndex != null) {
              setState(() {
                  _selectedIndex = null;
                  _targetRatio = 0.5;
                  _animateTo(_targetRatio, Curves.elasticOut);
              });
          }
      }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataMap = widget.riskData ?? {};
    final pass = (dataMap['Pass'] is num ? dataMap['Pass'] as num : 0).toInt();
    final user = (dataMap['User'] is num ? dataMap['User'] as num : 0).toInt();
    final token = (dataMap['Token'] is num ? dataMap['Token'] as num : 0).toInt();
    final total = pass + user + token;
    final hasData = total > 0;

    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
               return GestureDetector(
                 onTapUp: (details) => _onChartTapped(details, Size(constraints.maxWidth, constraints.maxHeight)),
                 behavior: HitTestBehavior.opaque,
                 child: AnimatedBuilder(
                   animation: _animation,
                   builder: (context, child) {
                     return CustomPaint(
                       size: Size(constraints.maxWidth, constraints.maxHeight),
                       painter: RiskGaugePainter(
                          ratio: _animation.value, 
                          selectedIndex: _selectedIndex,
                          hasData: hasData,
                       ),
                     );
                   },
                 ),
               );
            }
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildLegendIndicator(hasData ? Colors.redAccent : Colors.grey[300]!, 'Contraseña errónea', pass, 0, hasData),
            _buildLegendIndicator(hasData ? Colors.orange : Colors.grey[300]!, 'Usuario inexistente', user, 1, hasData),
            _buildLegendIndicator(hasData ? Colors.blue : Colors.grey[300]!, 'Token expirado', token, 2, hasData),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendIndicator(Color color, String text, int value, int index, bool hasData) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: hasData ? () => _onSegmentTapped(index) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
           color: isSelected ? color.withAlpha(51) : Colors.transparent,
           borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$text ($value)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.black87 : Colors.grey[600],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RiskGaugePainter extends CustomPainter {
  final double ratio;
  final int? selectedIndex;
  final bool hasData;

  RiskGaugePainter({required this.ratio, this.selectedIndex, required this.hasData});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = math.min(size.width / 2, size.height - 20) - 15;
    final strokeWidth = 50.0;

    // Ordered: Red, Orange, Blue -> Or grey if no data.
    final colors = hasData ? [
      Colors.redAccent.withAlpha(204), 
      Colors.orange.withAlpha(204),     
      Colors.blue.withAlpha(204),         
    ] : [
      Colors.grey[300]!,
      Colors.grey[300]!,
      Colors.grey[300]!,
    ];

    // Draw the 3 segments
    final totalAngle = math.pi; // Half circle
    final gapAngle = 0.08; // Gap between segments
    final segmentAngle = (totalAngle - (gapAngle * 2)) / 3;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = math.pi; // Start from left

    for (int i = 0; i < 3; i++) {
        // If a segment is selected, subtly dim the others
        if (hasData && selectedIndex != null && selectedIndex != i) {
           paint.color = colors[i].withAlpha(76);
        } else {
           paint.color = colors[i];
        }
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentAngle,
          false,
          paint,
        );
        startAngle += segmentAngle + gapAngle;
    }

    // Draw Needle
    // ratio goes from 0.0 (left) to 1.0 (right).  
    // Start at math.pi (left), end at 2*math.pi (right).
    final needleAngle = math.pi + (ratio * math.pi);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleAngle);

    final needlePaint = Paint()
      ..color = const Color(0xFF1E1E1E) // Dark slate/almost black
      ..style = PaintingStyle.fill;

    // Draw sharp needle shape pointing right (representing the current angle)
    final needlePath = Path();
    needlePath.moveTo(0, -5); // Base top
    needlePath.lineTo(radius + (strokeWidth / 2) + 8, 0); // Point
    needlePath.lineTo(0, 5); // Base bottom
    needlePath.close();

    canvas.drawPath(needlePath, needlePaint);
    canvas.drawCircle(const Offset(0, 0), 14, needlePaint);
    canvas.drawCircle(const Offset(0, 0), 4, Paint()..color = const Color(0xFF888888));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RiskGaugePainter oldDelegate) {
    return oldDelegate.ratio != ratio || 
           oldDelegate.selectedIndex != selectedIndex || 
           oldDelegate.hasData != hasData;
  }
}
