import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class AgeDistributionChart extends StatelessWidget {
  final Map<String, dynamic>? ageData;

  const AgeDistributionChart({super.key, required this.ageData});

  @override
  Widget build(BuildContext context) {
    final dataMap = ageData ?? {};
    final labels = ["<18", "18-25", "26-35", "36-45", "46+"];
    final List<FlSpot> spots = labels.asMap().entries.map((entry) {
      final val = (dataMap[entry.value] ?? 0).toDouble();
      return FlSpot(entry.key.toDouble(), val);
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 10, top: 10, bottom: 10),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int idx = value.round();
                  if (idx >= 0 && idx < labels.length && (value - idx).abs() < 0.1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(labels[idx], 
                        style: const TextStyle(
                          fontSize: 10, 
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        )
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              maxContentWidth: 150,
              getTooltipColor: (LineBarSpot touchedSpot) => Colors.orange[800]!.withOpacity(0.95),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'Grupo: ${labels[spot.x.toInt()]}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                    children: [
                      TextSpan(
                        text: '${spot.y.toInt()} usuarias',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: Colors.orange,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.orange,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    Colors.orange.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
