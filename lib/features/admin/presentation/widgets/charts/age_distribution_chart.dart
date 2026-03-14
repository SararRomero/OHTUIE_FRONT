import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AgeDistributionChart extends StatefulWidget {
  final Map<String, dynamic>? ageData;

  const AgeDistributionChart({super.key, required this.ageData});

  @override
  State<AgeDistributionChart> createState() => _AgeDistributionChartState();
}

class _AgeDistributionChartState extends State<AgeDistributionChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AgeDistributionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ageData != oldWidget.ageData) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataMap = widget.ageData ?? {};
    final labels = ["<18", "18-25", "26-35", "36-45", "46+"];
    
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 10, top: 10, bottom: 5),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final List<FlSpot> spots = labels.asMap().entries.map((entry) {
            final val = (dataMap[entry.value] ?? 0).toDouble();
            // Animate the Y value smoothly up from 0
            return FlSpot(entry.key.toDouble(), val * _animation.value);
          }).toList();

          return LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30, // Increased to prevent cutting off the text
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int idx = value.round();
                      if (idx >= 0 && idx < labels.length && (value - idx).abs() < 0.1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
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
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: Colors.orange,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.orange.withOpacity(0.5 * _animation.value),
                        Colors.orange.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
