import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class FlowAnalysisChart extends StatelessWidget {
  final Map<String, dynamic>? flowData;

  const FlowAnalysisChart({super.key, required this.flowData});

  @override
  Widget build(BuildContext context) {
    final dataMap = flowData ?? {};
    final List<double> values =
        dataMap.values.map<double>((e) => (e as num).toDouble()).toList();
    if (values.isEmpty) values.add(0);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: values.reduce((a, b) => math.max(a, b)) + 5,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: const Color(0xFFFFE5E9),
                width: 15,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }),
      ),
    );
  }
}
