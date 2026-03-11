import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'home_service.dart';
import 'symptoms/daily_log_service.dart';
import 'widgets/prediction_card.dart';
import 'utils/cycle_utils.dart';
import 'symptoms/add_symptoms_screen.dart';
import 'widgets/calendar_header.dart';
import 'widgets/calendar_month_selector.dart';
import 'widgets/calendar_day_item.dart';
import 'widgets/daily_log_summary.dart';
import 'widgets/ovulation_flower_painter.dart';
import 'edit_cycle_screen.dart';


class CalendarScreen extends StatefulWidget {
  final Map<String, dynamic>? predictionData;

  const CalendarScreen({super.key, this.predictionData});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late Map<String, dynamic> _predictionData;
  Map<String, dynamic>? _selectedDayLog;
  bool _isLoadingLog = false;

  final Map<String, Map<String, String>> _moodOptions = {
    'normal': {'label': 'Normal', 'imagePath': 'lib/assets/image/animo_normal.png'},
    'angry': {'label': 'Enojada', 'imagePath': 'lib/assets/image/enojada.png'},
    'happy': {'label': 'Feliz', 'imagePath': 'lib/assets/image/feliz.png'},
    'sad': {'label': 'Triste', 'imagePath': 'lib/assets/image/triste.png'},
    'calm': {'label': 'Tranquila', 'imagePath': 'lib/assets/image/tranquila.png'},
    'tired': {'label': 'Cansada', 'imagePath': 'lib/assets/image/cansada.png'},
  };

  final Map<String, Map<String, String>> _symptomOptions = {
    'aching_head': {'label': 'Dolor de cabeza', 'imagePath': 'lib/assets/image/dolor_de_cabeza.png'},
    'add_weight': {'label': 'Aumento de peso', 'imagePath': 'lib/assets/image/peso.png'},
    'cramps': {'label': 'Cólicos', 'imagePath': 'lib/assets/image/colicos.png'},
    'bloating': {'label': 'Hinchazón', 'imagePath': 'lib/assets/image/hinchazon.png'},
    'fatigue': {'label': 'Fatiga', 'imagePath': 'lib/assets/image/fatiga.png'},
  };

  final Map<String, String> _flowOptions = {
    'none': 'Ninguno',
    'light': 'Bajo',
    'medium': 'Normal',
    'heavy': 'Alto',
  };

  @override
  void initState() {
    super.initState();
    _predictionData = widget.predictionData ?? {};
    if (widget.predictionData == null) {
      _loadPredictions();
    }
    _loadDailyLog(_selectedDay);
  }

  Future<void> _loadPredictions() async {
    final result = await HomeService.getPredictions();
    if (mounted && result['success']) {
      setState(() {
        _predictionData = result['data'];
      });
    }
  }

  Future<void> _loadDailyLog(DateTime date) async {
    setState(() => _isLoadingLog = true);
    final result = await DailyLogService.getDailyLog(date);
    if (mounted) {
      setState(() {
        _selectedDayLog = result['success'] ? result['data'] : null;
        _isLoadingLog = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
    return months[month - 1];
  }

  Map<String, dynamic> _getDayPhaseInfo(DateTime date) {
    int avgCycle = _predictionData['avg_cycle_duration'] ?? 28;
    int periodDuration = _predictionData['period_duration'] ?? 5;
    
    DateTime lastPeriodStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (_predictionData['next_period_start'] != null) {
      DateTime nextPeriod = DateTime.parse(_predictionData['next_period_start']);
      lastPeriodStart = nextPeriod.subtract(Duration(days: avgCycle));
    }

    int currentCycleDay = date.difference(lastPeriodStart).inDays + 1;
    while (currentCycleDay > avgCycle) currentCycleDay -= avgCycle;
    while (currentCycleDay <= 0) currentCycleDay += avgCycle;

    DateTime ovulationDate = DateTime.parse(_predictionData['ovulation_date'] ?? DateTime.now().toIso8601String());
    DateTime fertileStart = DateTime.parse(_predictionData['fertile_window']?['start'] ?? DateTime.now().toIso8601String());
    
    int ovulationDay = ovulationDate.difference(lastPeriodStart).inDays + 1;
    while (ovulationDay > avgCycle) ovulationDay -= avgCycle;
    while (ovulationDay <= 0) ovulationDay += avgCycle;

    int fertileDay = fertileStart.difference(lastPeriodStart).inDays + 1;
    while (fertileDay > avgCycle) fertileDay -= avgCycle;
    while (fertileDay <= 0) fertileDay += avgCycle;

    return CycleUtils.getPhaseInfo(
      currentCycleDay: currentCycleDay,
      avgCycle: avgCycle,
      periodDuration: periodDuration,
      fertileDay: fertileDay,
      ovulationDay: ovulationDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime todayDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedDayPhase = _getDayPhaseInfo(todayDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              children: [
                const CalendarHeader(),
                const SizedBox(height: 30),
                _buildCalendarCard(),
                const SizedBox(height: 35),
                _buildSelectedDayDetails(selectedDayPhase),
                const SizedBox(height: 30),
                DailyLogSummary(
                  dailyLog: _selectedDayLog,
                  moodOptions: _moodOptions,
                  symptomOptions: _symptomOptions,
                  flowOptions: _flowOptions,
                ),
                const SizedBox(height: 30),
                _buildAddSymptomsSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final now = DateTime.now();
    final minDate = DateTime(now.year, now.month - 3);
    final maxDate = DateTime(now.year, now.month + 3);
    bool canGoBack = _focusedDay.isAfter(DateTime(minDate.year, minDate.month));
    bool canGoForward = _focusedDay.isBefore(DateTime(maxDate.year, maxDate.month));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          CalendarMonthSelector(
            focusedDay: _focusedDay,
            monthName: _getMonthName(_focusedDay.month),
            canGoBack: canGoBack,
            canGoForward: canGoForward,
            onPrevious: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
            onNext: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
          ),
          const SizedBox(height: 20),
          _buildWeekDaysRow(),
          const SizedBox(height: 10),
          _buildCalendarGrid(),
          const SizedBox(height: 15),
          _buildPhaseLegend(),
        ],
      ),
    );
  }

  Widget _buildWeekDaysRow() {
    const days = ["Lu", "Ma", "Mi", "Ju", "Vi", "Sa", "Do"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((d) => Text(d, style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500))).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    int startOffset = firstDayOfMonth.weekday - 1;
    List<Widget> dayWidgets = List.generate(startOffset, (_) => const SizedBox());
    
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, day);
      final phase = _getDayPhaseInfo(date);
      final isSelected = date.day == _selectedDay.day && date.month == _selectedDay.month && date.year == _selectedDay.year;
      final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
      
      Color dayColor = Colors.transparent;
      bool isOvulation = false;
      String phaseName = phase['currentPhaseText'];
      if (phaseName == "Menstruación") dayColor = const Color(0xFFEBD8F5);
      else if (phaseName == "Ventana Fértil") dayColor = const Color(0xFFD4E2FF);
      else if (phaseName == "Ovulación") { dayColor = Colors.transparent; isOvulation = true; }
      
      dayWidgets.add(
        CalendarDayItem(
          day: day,
          date: date,
          isSelected: isSelected,
          isToday: isToday,
          dayColor: dayColor,
          isOvulation: isOvulation,
          onTap: () {
            setState(() => _selectedDay = date);
            _loadDailyLog(date);
          },
        ),
      );
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildPhaseLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(const Color(0xFFEBD8F5), "Periodo"),
        const SizedBox(width: 15),
        _buildLegendItem(const Color(0xFFD4E2FF), "Fértil"),
        const SizedBox(width: 15),
        _buildLegendItem(const Color(0xFFFFB2C1), "Ovulación"),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _buildSelectedDayDetails(Map<String, dynamic> phase) {
    String formattedDate = "${_getMonthName(_selectedDay.month)} ${_selectedDay.day}";
    String phaseText = (phase['currentPhaseText'] ?? "").toLowerCase();
    int currentCycleDay = phase['currentCycleDay'] ?? 1;
    int fertileStartDay = phase['fertileDay'] ?? 1;
    
    String description = "Día $currentCycleDay de tu ciclo";
    if (phaseText == "menstruación") {
      description = "Día $currentCycleDay de tu periodo /\nDía $currentCycleDay de tu ciclo";
    } else if (phaseText == "ventana fértil") {
      int fertileDayNumber = currentCycleDay - fertileStartDay + 1;
      if (fertileDayNumber <= 0) {
         int avgCycle = _predictionData['avg_cycle_duration'] ?? 28;
         fertileDayNumber += avgCycle;
      }
      description = "Día $fertileDayNumber de tu ventana fértil /\nDía $currentCycleDay de tu ciclo";
    } else if (phaseText == "ovulación") {
      description = "Día de tu ovulación /\nDía $currentCycleDay de tu ciclo";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  description, 
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCycleScreen(initialData: _predictionData),
                ),
              );
              
              if (result != null) {
                // Here we would call HomeService.saveCycle(result['last_period'], etc.)
                // For now, we simulate a reload:
                _loadPredictions();
              }
            },
            child: Column(
              children: [
                Container(
                  width: 45, height: 45,
                  decoration: const BoxDecoration(color: Color(0xFFD4E2FF), shape: BoxShape.circle),
                  child: const Icon(Icons.water_drop_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 6),
                const Text("Editar ciclo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSymptomsSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
             await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSymptomsScreen()));
             _loadDailyLog(_selectedDay);
          },
          child: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.add, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Añade tus sintomas", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }
}
