import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class CalendarUsageChart extends StatefulWidget {
  final Map<String, dynamic>? usageData;

  const CalendarUsageChart({super.key, required this.usageData});

  @override
  State<CalendarUsageChart> createState() => _CalendarUsageChartState();
}

class _CalendarUsageChartState extends State<CalendarUsageChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
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
  void didUpdateWidget(CalendarUsageChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.usageData != oldWidget.usageData) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataMap = widget.usageData ?? {};
    
    // Generate dates for the current week starting from Monday
    final now = DateTime.now();
    // monday is 1, sunday is 7
    final daysToSubtract = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
    
    final List<double> rawData = [];
    final List<String> dayLabels = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      double val = 0.0;
      if (dataMap.containsKey(dateStr)) {
        val = (dataMap[dateStr] as num).toDouble();
      }

      rawData.add(val);
      dayLabels.add(DateFormat('E', 'es').format(date).capitalize());
    }

    final double maxVal =
        rawData.reduce(math.max) > 0 ? rawData.reduce(math.max) : 1;
    final List<double> normalizedData =
        rawData.map((e) => e / maxVal).toList();
        
    final Color chartColor = Colors.purple[300]!;

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
                  final isSelected = selectedIndex == index;

                  // Minimum visual bar height of 2% when value is 0 so the pill still minimally shows if desired
                  // However, AnimatedBarChart sets height down to 0 explicitly. Let's do 0 to match.

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                         selectedIndex = index;
                      });
                    },
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
                                  ? [chartColor, chartColor.withOpacity(0.7)]
                                  : [
                                      chartColor.withOpacity(0.2),
                                      chartColor.withOpacity(0.4)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: chartColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: isSelected && value > 0 // Only show center pip if height > 0
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
                            color: isSelected ? chartColor : Colors.grey[400],
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
        if (selectedIndex != -1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: chartColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Valor: ${rawData[selectedIndex].toInt()}",
                style: TextStyle(
                    color: chartColor.withOpacity(0.8),
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

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}
