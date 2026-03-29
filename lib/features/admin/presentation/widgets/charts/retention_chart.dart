import 'package:flutter/material.dart';
import 'dart:math' as math;

class RetentionChart extends StatefulWidget {
  final Map<String, dynamic>? retentionData;

  const RetentionChart({super.key, required this.retentionData});

  @override
  State<RetentionChart> createState() => _RetentionChartState();
}

class _RetentionChartState extends State<RetentionChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _defaultRatio = 0.0;
  double _targetRatio = 0.0;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1000),
    );

    _calculateRatio();

    _animation = Tween<double>(begin: 0.0, end: _targetRatio).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(RetentionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.retentionData != oldWidget.retentionData) {
       _calculateRatio();
       _animateTo(_targetRatio, Curves.easeOutCubic);
    }
  }

  void _calculateRatio() {
    final dataMap = widget.retentionData ?? {};
    final active = (dataMap['Activas'] ?? 0 as num).toDouble();
    final blocked = (dataMap['Bloqueadas'] ?? 0 as num).toDouble();
    final deleted = (dataMap['Eliminadas'] ?? 0 as num).toDouble();
    final total = active + blocked + deleted;
    
    if (total > 0) {
      _defaultRatio = active / total;
    } else {
      _defaultRatio = 0.0;
    }

    if (_selectedIndex == null) {
      _targetRatio = _defaultRatio;
    }
  }

  void _animateTo(double target, Curve curve) {
    _animation = Tween<double>(begin: _animation.value, end: target).animate(
      CurvedAnimation(parent: _controller, curve: curve)
    );
    _controller.forward(from: 0.0);
  }

  void _onSegmentTapped(int index) {
      setState(() {
         // Reset if same is tapped
         if (_selectedIndex == index) {
            _selectedIndex = null;
            _targetRatio = _defaultRatio;
            _animateTo(_targetRatio, Curves.easeOutCubic);
            return;
         }
         
         _selectedIndex = index;
         // 3 segments: 0 -> Left, 1 -> Center, 2 -> Right
         // 1/6 (0.166) is center of first third
         // 3/6 (0.5) is center of second third
         // 5/6 (0.833) is center of third third
         if (index == 0) _targetRatio = 1 / 6;
         if (index == 1) _targetRatio = 3 / 6;
         if (index == 2) _targetRatio = 5 / 6;
         
         _animateTo(_targetRatio, Curves.easeOutBack);
      });
  }

  void _onChartTapped(TapUpDetails details, Size size) {
      final center = Offset(size.width / 2, size.height - 20); 
      final dx = details.localPosition.dx - center.dx;
      final dy = details.localPosition.dy - center.dy;
      // In atan2, top half is -pi to 0.
      final angle = math.atan2(dy, dx);
      if (angle < 0) {
          // map -pi (left) ... 0 (right) to ratio 0.0 ... 1.0
          final ratio = (angle + math.pi) / math.pi;
          if (ratio < 0.33) _onSegmentTapped(0);
          else if (ratio < 0.66) _onSegmentTapped(1);
          else _onSegmentTapped(2);
      } else {
          // Tap below baseline resets
          if (_selectedIndex != null) {
              setState(() {
                  _selectedIndex = null;
                  _targetRatio = _defaultRatio;
                  _animateTo(_targetRatio, Curves.easeOutCubic);
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
    final dataMap = widget.retentionData ?? {};
    final active = (dataMap['Activas'] ?? 0 as num).toInt();
    final blocked = (dataMap['Bloqueadas'] ?? 0 as num).toInt();
    final deleted = (dataMap['Eliminadas'] ?? 0 as num).toInt();
    final total = active + blocked + deleted;

    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No hay datos disponibles', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

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
                       painter: GaugePainter(ratio: _animation.value, selectedIndex: _selectedIndex),
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
            _buildLegendIndicator(const Color(0xFFCCDDFF), 'Activas', active, 0),
            _buildLegendIndicator(const Color(0xFFEBD8F5), 'Bloqueadas', blocked, 1),
            _buildLegendIndicator(const Color(0xFFFFD0D5), 'Eliminadas', deleted, 2),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendIndicator(Color color, String text, int value, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onSegmentTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
           color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
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

class GaugePainter extends CustomPainter {
  final double ratio;
  final int? selectedIndex;

  GaugePainter({required this.ratio, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    // Keep gauge centered and proportional. 
    // Decrease the radius slighty to give room for the needle tip
    final center = Offset(size.width / 2, size.height - 20);
    final radius = math.min(size.width / 2, size.height - 20) - 15;
    final strokeWidth = 50.0;

    // Ordered by request: Blue, Purple, Pink
    final colors = [
      const Color(0xFFCCDDFF), // Activas
      const Color(0xFFEBD8F5), // Bloqueadas
      const Color(0xFFFFD0D5), // Eliminadas
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
        if (selectedIndex != null && selectedIndex != i) {
           paint.color = colors[i].withOpacity(0.4);
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
    needlePath.lineTo(radius + (strokeWidth / 2) + 8, 0); // Point (tip extending beyond stroke)
    needlePath.lineTo(0, 5); // Base bottom
    needlePath.close();

    canvas.drawPath(needlePath, needlePaint);

    // Draw center circle for needle base
    canvas.drawCircle(const Offset(0, 0), 14, needlePaint);
    
    // Draw tiny inner dot for realism
    canvas.drawCircle(const Offset(0, 0), 4, Paint()..color = const Color(0xFF888888));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.ratio != ratio || oldDelegate.selectedIndex != selectedIndex;
  }
}
