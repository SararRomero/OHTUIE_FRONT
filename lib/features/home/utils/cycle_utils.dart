import 'package:flutter/material.dart';

class CycleUtils {
  static Map<String, dynamic> getPhaseInfo({
    required int currentCycleDay,
    required int avgCycle,
    required int periodDuration,
    required int fertileDay,
    required int ovulationDay,
  }) {
    // Petal Rainbow Palette (Vibrant & Unique)
    const Color colorMenstruation = Color(0xFFFFB5E1); // Original Pink/Coral
    const Color colorFollicular = Color(0xFFD1E3FF);    // New Soft Blue for follicular phase
    const Color colorFertileWindow = Color(0xFF97BAA5); // Muted Green for fertile window
    const Color colorOvulation = Color(0xFF4A90E2);    // Strong Blue for ovulation
    const Color colorLuteal = Color(0xFFD2BDFF);       // Original Luteal Purple

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

    // Color Interpolation Logic (REMOVED for solid segments)
    // The painter's gradient handles the fixed color segments exactly at the markers.

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
