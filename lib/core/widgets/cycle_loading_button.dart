import 'package:flutter/material.dart';
import 'dart:ui';
import 'ripple_painter.dart';

class CycleLoadingButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? loadingColor;
  final double width;
  final double height;
  final double borderRadius;
  final double fontSize;
  final bool showBorderAnimation;
  final bool useBorealisAnimation;

  const CycleLoadingButton({
    super.key,
    this.text,
    this.child,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.loadingColor,
    this.width = double.infinity,
    this.height = 55,
    this.borderRadius = 30,
    this.fontSize = 18,
    this.showBorderAnimation = true,
    this.useBorealisAnimation = false,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  State<CycleLoadingButton> createState() => _CycleLoadingButtonState();
}

class _CycleLoadingButtonState extends State<CycleLoadingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CycleLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
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
    final buttonColor = widget.backgroundColor ?? const Color(0xFFFFCCE5);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 1. Background Ripple Animation (Layer 1)
        if (widget.isLoading && widget.useBorealisAnimation)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RipplePainter(
                      animation: _controller,
                      colors: [
                        const Color(0xFFFF4081).withOpacity(0.5),
                        const Color(0xFFFF80AB).withOpacity(0.3),
                      ],
                      // Start exactly outside the button
                      minRadius: widget.borderRadius + 1.0,
                    ),
                  );
                },
              ),
            ),
          ),
        
        // 2. Main Button (Layer 2)
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: ElevatedButton(
            onPressed: isEnabled ? widget.onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              disabledBackgroundColor: buttonColor.withOpacity(widget.isLoading ? 0.8 : 0.6),
              foregroundColor: widget.textColor ?? Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              padding: EdgeInsets.zero,
            ),
            child: widget.child ?? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) 
                      Icon(widget.icon, color: widget.textColor ?? Colors.white, size: 22),
                    if (widget.text != null && widget.text!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        widget.text!,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
          ),
        ),

        // 3. Border Animation (Layer 3 - Optional)
        if (widget.isLoading && widget.showBorderAnimation)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _BorderPainter(
                      progress: _controller.value,
                      color: widget.loadingColor ?? Colors.white,
                      borderRadius: widget.borderRadius,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _BorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderRadius;

  _BorderPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    final path = Path()..addRRect(rRect);
    final metrics = path.computeMetrics();
    
    for (final metric in metrics) {
      final totalLength = metric.length;
      final segmentLength = totalLength * 0.25; // 25% of the perimeter
      
      // Animate the segment start position
      final start = (totalLength * progress) % totalLength;
      final end = (start + segmentLength) % totalLength;
      
      if (start < end) {
        canvas.drawPath(metric.extractPath(start, end), paint);
      } else {
        // Handle wrap around path end
        canvas.drawPath(metric.extractPath(start, totalLength), paint);
        canvas.drawPath(metric.extractPath(0, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
