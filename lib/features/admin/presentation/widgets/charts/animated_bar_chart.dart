import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBarChart extends StatefulWidget {
  final Map<String, dynamic> dataMap;
  final Color color;
  final int selectedIndex;
  final int weekOffset;
  final Function(int) onTap;

  const AnimatedBarChart({
    super.key,
    required this.dataMap,
    required this.color,
    required this.selectedIndex,
    required this.weekOffset,
    required this.onTap,
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Map<String, dynamic> _oldDataMap;

  @override
  void initState() {
    super.initState();
    _oldDataMap = widget.dataMap;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-animate if the data map actually changed or the week offset changed
    if (widget.weekOffset != oldWidget.weekOffset || 
        !_isMapEqual(widget.dataMap, oldWidget.dataMap)) {
      _controller.reset();
      _controller.forward();
    }
  }

  bool _isMapEqual(Map<String, dynamic> m1, Map<String, dynamic> m2) {
    if (m1.length != m2.length) return false;
    for (final key in m1.keys) {
      if (m1[key] != m2[key]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate dates for the week corresponding to weekOffset
    final now = DateTime.now();
    final monday = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: widget.weekOffset * 7));
    final List<double> rawData = [];
    final List<String> dayLabels = [];
    final weekDays = ["L", "M", "Mi", "J", "V", "S", "D"];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      double val = 0.0;
      if (widget.dataMap.containsKey(dateStr)) {
        val = (widget.dataMap[dateStr] as num).toDouble();
      }

      rawData.add(val);
      dayLabels.add(weekDays[i]);
    }

    final double maxVal =
        rawData.reduce(math.max) > 0 ? rawData.reduce(math.max) : 1;
    final List<double> normalizedData =
        rawData.map((e) => e / maxVal).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: normalizedData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final isSelected = widget.selectedIndex == index;

                  return GestureDetector(
                    onTap: () => widget.onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 24,
                          height: 90 * value * _animation.value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isSelected
                                  ? [widget.color, widget.color.withOpacity(0.7)]
                                  : [
                                      widget.color.withOpacity(0.2),
                                      widget.color.withOpacity(0.4)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: widget.color.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabels[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? widget.color : Colors.grey[400],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        if (widget.selectedIndex != -1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Valor: ${rawData[widget.selectedIndex].toInt()}",
                style: TextStyle(
                    color: widget.color.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "Toca una barra para ver detalles",
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}
