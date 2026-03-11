import 'package:flutter/material.dart';

class CycleUtils {
  static Map<String, dynamic> getPhaseInfo({
    required int currentCycleDay,
    required int avgCycle,
    required int periodDuration,
    required int fertileDay,
    required int ovulationDay,
  }) {
    // User's Verified Card Palette
    const Color colorMenstruation = Color(0xFFEBD8F5); // Purple (matching card)
    const Color colorFollicular = Color(0xFFE8F5E9);   // Soft Green
    const Color colorFertileWindow = Color(0xFFD4E2FF); // Aqua Blue (matching card)
    const Color colorOvulation = Color(0xFFFFE5E9);    // Soft Pink (matching card)
    const Color colorLuteal = Color(0xFFFFF3E0);      // Soft Peach

    String currentPhaseText = "";
    Color phaseColor = colorFollicular;
    String countdownLabel = "";
    int daysToNext = 0;
    Color nextStageColor = Colors.grey;
    bool isToday = false;

    if (currentCycleDay <= periodDuration) {
      currentPhaseText = "Menstruación";
      phaseColor = colorMenstruation;
      countdownLabel = "Ventana Fértil en";
      daysToNext = fertileDay - currentCycleDay;
      nextStageColor = colorFollicular;
    } else if (currentCycleDay < fertileDay) {
      currentPhaseText = "Fase Folicular";
      phaseColor = colorFollicular;
      countdownLabel = "Ventana Fértil en";
      daysToNext = fertileDay - currentCycleDay;
      nextStageColor = colorFertileWindow;
    } else if (currentCycleDay < ovulationDay) {
      currentPhaseText = "Ventana Fértil";
      phaseColor = colorFertileWindow;
      countdownLabel = "Ovulación en";
      daysToNext = ovulationDay - currentCycleDay;
      nextStageColor = colorOvulation;
    } else if (currentCycleDay == ovulationDay) {
      currentPhaseText = "Ovulación";
      phaseColor = colorOvulation;
      countdownLabel = "Ovulación";
      daysToNext = 0;
      isToday = true;
      nextStageColor = colorLuteal;
    } else {
      currentPhaseText = "Fase Lútea";
      phaseColor = colorLuteal;
      countdownLabel = "Próximo Periodo en";
      daysToNext = avgCycle - currentCycleDay + 1;
      nextStageColor = colorMenstruation;
    }

    // Color Interpolation Logic
    // Start transitioning 3 days before the next event
    if (!isToday && daysToNext <= 3 && daysToNext > 0) {
      double t = (4 - daysToNext) / 4.0; 
      phaseColor = Color.lerp(phaseColor, nextStageColor, t) ?? phaseColor;
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
