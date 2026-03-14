import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RetentionChart extends StatefulWidget {
  final Map<String, dynamic>? retentionData;

  const RetentionChart({super.key, required this.retentionData});

  @override
  State<RetentionChart> createState() => _RetentionChartState();
}

class _RetentionChartState extends State<RetentionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final dataMap = widget.retentionData ?? {};
    final active = (dataMap['Activas'] ?? 0 as num).toDouble();
    final blocked = (dataMap['Bloqueadas'] ?? 0 as num).toDouble();
    final deleted = (dataMap['Eliminadas'] ?? 0 as num).toDouble();
    final total = active + blocked + deleted;

    if (total == 0) {
      return const Center(
        child: Text('No hay datos disponibles',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 140, // Reduced height since it's only a half circle
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: 180, // Start from the left
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: _showingSections(active, blocked, deleted, total),
                ),
              ),
              // Needle pointing to current "score" (proportion of active users)
              Positioned(
                bottom: 25,
                child: _buildNeedle(active / total),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendIndicator(Colors.blue[300]!, 'Activas', active.toInt()),
            _buildLegendIndicator(Colors.orange[300]!, 'Bloqueadas', blocked.toInt()),
            _buildLegendIndicator(Colors.pink[300]!, 'Eliminadas', deleted.toInt()),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections(
      double active, double blocked, double deleted, double total) {
    
    // To make it a semi-circle with fl_chart, we add a transparent section that takes up 50% of the pie (the bottom half).
    // The visual sections will take up the remaining 50% proportionally.
    // If the total is 100, the transparent section is 100.
    final emptyHalf = total;

    return [
      if (active > 0)
        PieChartSectionData(
          color: Colors.blue[300],
          value: active,
          title: '${active.toInt()}',
          radius: touchedIndex == 0 ? 50.0 : 40.0,
          titleStyle: TextStyle(
            fontSize: touchedIndex == 0 ? 16.0 : 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (blocked > 0)
        PieChartSectionData(
          color: Colors.orange[300],
          value: blocked,
          title: '${blocked.toInt()}',
          radius: touchedIndex == 1 ? 50.0 : 40.0,
          titleStyle: TextStyle(
            fontSize: touchedIndex == 1 ? 16.0 : 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (deleted > 0)
        PieChartSectionData(
          color: Colors.pink[300],
          value: deleted,
          title: '${deleted.toInt()}',
          radius: touchedIndex == 2 ? 50.0 : 40.0,
          titleStyle: TextStyle(
            fontSize: touchedIndex == 2 ? 16.0 : 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      // The invisible bottom half
      PieChartSectionData(
          color: Colors.transparent,
          value: emptyHalf,
          title: '',
          radius: 40,
       ),
    ];
  }

  Widget _buildNeedle(double ratio) {
    // Rotation logic for the needle from 0 (left) to pi (right)
    // ratio is 0.0 to 1.0. We want the angle to be from -pi/2 to pi/2
    final angle = (ratio * 3.14159) - (3.14159 / 2);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: angle,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 4,
            height: 48, // Length of the needle
            decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              )
            ),
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendIndicator(Color color, String text, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$text ($value)',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}
