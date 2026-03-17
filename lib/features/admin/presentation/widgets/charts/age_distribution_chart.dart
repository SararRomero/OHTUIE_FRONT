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
    final colors = [
      Colors.blue[300]!,
      Colors.purple[300]!,
      Colors.orange[300]!,
      Colors.pink[300]!,
      Colors.teal[300]!,
    ];

    double total = 0;
    dataMap.forEach((key, value) => total += (value as num).toDouble());

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: labels.asMap().entries.map((entry) {
                    final value = (dataMap[entry.value] ?? 0).toDouble();
                    final isTouched = false; // We can add touch logic if needed
                    final radius = isTouched ? 30.0 : 25.0;
                    
                    return PieChartSectionData(
                      color: colors[entry.key],
                      value: value > 0 ? value * _animation.value : 0.1, // Show small slice if 0
                      title: '',
                      radius: radius,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: labels.asMap().entries.map((entry) {
                  final value = (dataMap[entry.value] ?? 0).toInt();
                  final percentage = total > 0 ? (value / total * 100).toStringAsFixed(1) : "0";
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[entry.key],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "$value ($percentage%)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
