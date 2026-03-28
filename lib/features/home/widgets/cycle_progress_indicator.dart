import 'package:flutter/material.dart';
import '../utils/cycle_utils.dart';
import 'cycle_progress_painter.dart';
import '../calendar_screen.dart';

class CycleProgressIndicator extends StatefulWidget {
  final Map<String, dynamic> predictionData;

  const CycleProgressIndicator({super.key, required this.predictionData});

  @override
  State<CycleProgressIndicator> createState() => CycleProgressIndicatorState();
}

class CycleProgressIndicatorState extends State<CycleProgressIndicator> with SingleTickerProviderStateMixin {
  String _indicatorMessage = "";
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  String? _glowingMarker; // "fertile", "ovulation", "period", or null (handle)

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );
    
    _glowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _glowingMarker = null);
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void triggerGlow({String? markerType}) {
    setState(() => _glowingMarker = markerType);
    _glowController.reset();
    _glowController.forward();
  }

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

    double progress = currentCycleDay / avgCycle;

    DateTime ovulationDate = DateTime.parse(widget.predictionData['ovulation_date'] ?? today.toIso8601String());
    DateTime fertileStart = DateTime.parse(widget.predictionData['fertile_window']?['start'] ?? today.toIso8601String());
    DateTime fertileEnd = DateTime.parse(widget.predictionData['fertile_window']?['end'] ?? today.toIso8601String());
    
    int ovulationDay = ovulationDate.difference(lastPeriodStart).inDays + 1;
    while (ovulationDay > avgCycle) ovulationDay -= avgCycle;
    while (ovulationDay <= 0) ovulationDay += avgCycle;

    int fertileDay = fertileStart.difference(lastPeriodStart).inDays + 1;
    while (fertileDay > avgCycle) fertileDay -= avgCycle;
    while (fertileDay <= 0) fertileDay += avgCycle;

    int fertileEndDay = fertileEnd.difference(lastPeriodStart).inDays + 1;
    while (fertileEndDay > avgCycle) fertileEndDay -= avgCycle;
    while (fertileEndDay <= 0) fertileEndDay += avgCycle;

    final phaseInfo = CycleUtils.getPhaseInfo(
      currentCycleDay: currentCycleDay,
      avgCycle: avgCycle,
      periodDuration: periodDuration,
      fertileDay: fertileDay,
      fertileEndDay: fertileEndDay,
      ovulationDay: ovulationDay,
    );

    Color phaseColor = phaseInfo['phaseColor'];
    String countdownLabel = phaseInfo['countdownLabel'];
    String countdownText = phaseInfo['countdownText'];
    
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
              width: 275,
              height: 275,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent, 
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF79AB0).withAlpha(60), // Original Pink glow
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return SizedBox(
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
                      glowFactor: _glowAnimation.value,
                      glowingMarker: _glowingMarker,
                    ),
                  ),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarScreen(predictionData: widget.predictionData),
                  ),
                );
              },
              child: Column(
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
                      style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
