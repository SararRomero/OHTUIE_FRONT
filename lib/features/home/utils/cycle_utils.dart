import 'package:flutter/material.dart';

class CycleUtils {
  static Map<String, dynamic> getPhaseInfo({
    required int currentCycleDay,
    required int avgCycle,
    required int periodDuration,
    required int fertileDay,
    required int fertileEndDay,
    required int ovulationDay,
  }) {
    // Petal Rainbow Palette
    // Paleta Armonizada con las Tarjetas
    const Color colorMenstruation = Color(0xFFEBD8F5); // Morado
    const Color colorFollicular = Color(0xFFF5F0FF);    // Lavanda pálido
    const Color colorFertileWindow = Color(0xFFD4E2FF); // Azul
    const Color colorOvulation = Color(0xFFFFADB9);    // Rosa (Más vibrante para mejor visibilidad)
    const Color colorLuteal = Color(0xFFFFE0CC);       // Naranja Pastel (Nuevo)

    String currentPhaseText = "";
    Color phaseColor = colorFollicular;
    String countdownLabel = "";
    int daysToNext = 0;
    Color nextStageColor = Colors.grey;
    bool isToday = false;

    if (currentCycleDay > avgCycle) {
      currentPhaseText = "Retraso";
      phaseColor = const Color(0xFFFFB2C1); // Coral suave para retraso
      countdownLabel = "Días de retraso";
      daysToNext = currentCycleDay - avgCycle;
      nextStageColor = colorMenstruation;
    } else if (currentCycleDay <= periodDuration) {
      currentPhaseText = "Menstruación";
      phaseColor = colorMenstruation;
      countdownLabel = "Ventana Fértil en";
      daysToNext = (fertileDay >= currentCycleDay) ? (fertileDay - currentCycleDay) : (fertileDay + avgCycle - currentCycleDay);
      nextStageColor = colorFollicular;
    } else if (currentCycleDay == ovulationDay) {
      currentPhaseText = "Ovulación";
      phaseColor = colorOvulation;
      countdownLabel = "Ovulación";
      daysToNext = 0;
      isToday = true;
      nextStageColor = colorLuteal;
    } else if (currentCycleDay >= fertileDay && currentCycleDay <= fertileEndDay) {
      currentPhaseText = "Ventana Fértil";
      phaseColor = colorFertileWindow;
      countdownLabel = "Ovulación en";
      daysToNext = (ovulationDay >= currentCycleDay) ? (ovulationDay - currentCycleDay) : (ovulationDay + avgCycle - currentCycleDay);
      nextStageColor = colorOvulation;
    } else if (currentCycleDay < fertileDay) {
      currentPhaseText = "Fase Folicular";
      phaseColor = colorFollicular;
      countdownLabel = "Ventana Fértil en";
      daysToNext = fertileDay - currentCycleDay;
      nextStageColor = colorFertileWindow;
    } else {
      currentPhaseText = "Fase Lútea";
      phaseColor = colorLuteal;
      countdownLabel = "Próximo Periodo en";
      daysToNext = (avgCycle >= currentCycleDay) ? (avgCycle - currentCycleDay + 1) : 1;
      nextStageColor = colorMenstruation;
    }

    return {
      'currentPhaseText': currentPhaseText,
      'phaseColor': phaseColor,
      'countdownLabel': (currentCycleDay > avgCycle) ? "Días de retraso" : (isToday ? "Ovulación" : countdownLabel),
      'countdownText': (currentCycleDay > avgCycle) ? "$daysToNext" : (isToday ? "Hoy" : "$daysToNext días"),
      'nextStageColor': nextStageColor,
      'isToday': isToday,
      'currentCycleDay': currentCycleDay,
      'fertileDay': fertileDay,
      'fertileEndDay': fertileEndDay,
    };
  }
}
