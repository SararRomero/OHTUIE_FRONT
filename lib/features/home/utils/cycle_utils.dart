import 'package:flutter/material.dart';

class CycleUtils {
  static Map<String, dynamic> getPhaseInfo({
    required int currentCycleDay,
    required int avgCycle,
    required int periodDuration,
    required int fertileDay,
    required int ovulationDay,
  }) {
    String currentPhaseText = "";
    Color phaseColor = const Color(0xFFCAFFBF);
    String countdownLabel = "";
    int daysToNext = 0;
    Color nextStageColor = Colors.grey;
    bool isToday = false;

    if (currentCycleDay <= periodDuration) {
      currentPhaseText = "Menstruación";
      phaseColor = const Color(0xFFFFADAD);
      countdownLabel = "Ventana Fértil en";
      daysToNext = fertileDay - currentCycleDay;
      nextStageColor = const Color(0xFFCAFFBF);
    } else if (currentCycleDay < fertileDay) {
      currentPhaseText = "Fase Folicular";
      phaseColor = const Color(0xFFCAFFBF);
      countdownLabel = "Ventana Fértil en";
      daysToNext = fertileDay - currentCycleDay;
      nextStageColor = const Color(0xFFFDFFB6);
    } else if (currentCycleDay < ovulationDay) {
      currentPhaseText = "Ventana Fértil";
      phaseColor = const Color(0xFFFDFFB6);
      countdownLabel = "Ovulación en";
      daysToNext = ovulationDay - currentCycleDay;
      nextStageColor = const Color(0xFFFFD6A5);
    } else if (currentCycleDay == ovulationDay) {
      currentPhaseText = "Ovulación";
      phaseColor = const Color(0xFFFFD6A5);
      countdownLabel = "Ovulación"; // For "Hoy" state
      daysToNext = 0;
      isToday = true;
      nextStageColor = const Color(0xFFFFADAD);
    } else {
      currentPhaseText = "Fase Lútea";
      phaseColor = const Color(0xFFD7B9FF);
      countdownLabel = "Próximo Periodo en";
      daysToNext = avgCycle - currentCycleDay + 1;
      nextStageColor = const Color(0xFFFFADAD);
    }

    return {
      'currentPhaseText': currentPhaseText,
      'phaseColor': phaseColor,
      'countdownLabel': isToday ? "Ovulación" : countdownLabel,
      'countdownText': isToday ? "Hoy" : "$daysToNext días",
      'nextStageColor': nextStageColor,
      'isToday': isToday,
      'currentCycleDay': currentCycleDay,
      'fertileDay': fertileDay,
    };
  }
}
