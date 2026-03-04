import 'package:flutter/material.dart';
import '../utils/cycle_utils.dart';
import 'cycle_progress_painter.dart';

class CycleProgressIndicator extends StatefulWidget {
  final Map<String, dynamic> predictionData;

  const CycleProgressIndicator({super.key, required this.predictionData});

  @override
  State<CycleProgressIndicator> createState() => _CycleProgressIndicatorState();
}

class _CycleProgressIndicatorState extends State<CycleProgressIndicator> {
  String _indicatorMessage = "";

  @override
  Widget build(BuildContext context) {
    // --- LOGIC ---
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    int avgCycle = widget.predictionData['avg_cycle_duration'] ?? 28;
    int periodDuration = widget.predictionData['period_duration'] ?? 5;
    
    DateTime lastPeriodStart = today;
    if (widget.predictionData['next_period_start'] != null) {
      DateTime nextPeriod = DateTime.parse(widget.predictionData['next_period_start']);
      lastPeriodStart = nextPeriod.subtract(Duration(days: avgCycle));
    }

    int currentCycleDay = today.difference(lastPeriodStart).inDays + 1;
    if (currentCycleDay > avgCycle) currentCycleDay = (currentCycleDay % avgCycle);
    if (currentCycleDay <= 0) currentCycleDay = 1;

    double progress = (currentCycleDay - 1) / avgCycle;

    DateTime ovulationDate = DateTime.parse(widget.predictionData['ovulation_date'] ?? today.toIso8601String());
    DateTime fertileStart = DateTime.parse(widget.predictionData['fertile_window']?['start'] ?? today.toIso8601String());
    
    int ovulationDay = ovulationDate.difference(lastPeriodStart).inDays + 1;
    int fertileDay = fertileStart.difference(lastPeriodStart).inDays + 1;

    final phaseInfo = CycleUtils.getPhaseInfo(
      currentCycleDay: currentCycleDay,
      avgCycle: avgCycle,
      periodDuration: periodDuration,
      fertileDay: fertileDay,
      ovulationDay: ovulationDay,
    );

    Color phaseColor = phaseInfo['phaseColor'];
    String countdownLabel = phaseInfo['countdownLabel'];
    String countdownText = phaseInfo['countdownText'];
    Color nextStageColor = phaseInfo['nextStageColor'];
    bool isToday = phaseInfo['isToday'];

    return Column(
      children: [
        if (_indicatorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _indicatorMessage,
              style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: phaseColor.withAlpha(30),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: CycleProgressPainter(
                  progress: progress, 
                  color: phaseColor,
                  avgCycle: avgCycle,
                  fertileDay: fertileDay,
                  ovulationDay: ovulationDay,
                  periodDuration: periodDuration,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  countdownLabel,
                  style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  countdownText,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12, width: 1.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    "Día $currentCycleDay del ciclo",
                    style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
