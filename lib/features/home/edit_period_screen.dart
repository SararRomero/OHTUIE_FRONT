import 'package:flutter/material.dart';
import 'home_service.dart';

class EditPeriodScreen extends StatefulWidget {
  const EditPeriodScreen({super.key});

  @override
  State<EditPeriodScreen> createState() => _EditPeriodScreenState();
}

class _EditPeriodScreenState extends State<EditPeriodScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  int _periodDuration = 5;
  bool _isLoading = true;
  bool _selectingStartDate = true;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _savedCycles = [];
  String? _editingCycleId;
  
  List<DateTime> _getMonthsToDisplay() {
    final now = DateTime.now();
    List<DateTime> months = List.generate(4, (index) => DateTime(now.year, now.month - 3 + index));
    
    if (_selectedEndDate != null) {
      final lastMonthInList = months.last;
      if (_selectedEndDate!.year > lastMonthInList.year || 
          (_selectedEndDate!.year == lastMonthInList.year && _selectedEndDate!.month > lastMonthInList.month)) {
        months.add(DateTime(_selectedEndDate!.year, _selectedEndDate!.month));
      }
    }
    return months;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentMonth());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentMonth() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          1250.0, 
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final results = await Future.wait([
      HomeService.getPredictions(),
      HomeService.getCycles(),
    ]);

    if (mounted) {
      final predictionResult = results[0];
      final cyclesResult = results[1];

      setState(() {
        if (predictionResult['success']) {
          _periodDuration = predictionResult['data']['period_duration'] ?? 5;
        }
        
        if (cyclesResult['success']) {
          _savedCycles = cyclesResult['data'];
          _checkActivePeriod();
        }
        _isLoading = false;
      });
    }
  }

  void _checkActivePeriod() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Only auto-select if today is actually WITHIN a saved cycle
    for (var cycle in _savedCycles) {
      final start = DateTime.parse(cycle['start_date']);
      final end = cycle['end_date'] != null 
          ? DateTime.parse(cycle['end_date']) 
          : start.add(Duration(days: (_periodDuration > 0 ? _periodDuration : 5) - 1));
      
      // If today is within [start, end], show it as the active selection
      if ((today.isAtSameMomentAs(start) || today.isAfter(start)) && 
          (today.isAtSameMomentAs(end) || today.isBefore(end))) {
        _selectedStartDate = start;
        _selectedEndDate = end;
        _editingCycleId = cycle['id'];
        return; 
      }
    }
    
    // If we reach here, no active cycle for today
    _selectedStartDate = null;
    _selectedEndDate = null;
    _editingCycleId = null;
  }

  @override
  Widget build(BuildContext context) {
    final monthsToDisplay = _getMonthsToDisplay();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildCustomAppBar(),
                Expanded(
                  child: _isLoading && _savedCycles.isEmpty
                    ? const Column(
                        children: [
                          LinearProgressIndicator(
                            color: Color(0xFFFF9EAF),
                            backgroundColor: Colors.transparent,
                            minHeight: 2,
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 150),
                        itemCount: monthsToDisplay.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 30),
                        itemBuilder: (context, index) => _buildMonthCalendar(monthsToDisplay[index]),
                      ),
                ),
              ],
            ),
            if (!(_isLoading && _savedCycles.isEmpty))
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildSaveButton(),
              ),
            if (_isLoading && _savedCycles.isNotEmpty)
              Container(
                color: Colors.white.withOpacity(0.3),
                child: const Column(
                  children: [
                    SizedBox(height: 80), // Approximated height of CustomAppBar
                    LinearProgressIndicator(
                      color: Color(0xFFFF9EAF),
                      backgroundColor: Colors.transparent,
                      minHeight: 2,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFF5F5F5)),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Edita tu periodo',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }


  Widget _buildMonthCalendar(DateTime month) {
    final months = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    final yearMonthStr = "${months[month.month - 1]} ${month.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 15),
          child: Text(
            yearMonthStr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildWeekdayHeader(),
              const SizedBox(height: 15),
              _buildDaysGrid(month),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final days = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((d) => Text(d, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 13))).toList(),
    );
  }

  Widget _buildDaysGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final startingWeekday = firstDay.weekday % 7;
    final now = DateTime.now();

    List<Widget> dayWidgets = [];
    
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int i = 1; i <= lastDay; i++) {
      final date = DateTime(month.year, month.month, i);
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      
      // Check if this date is part of CURRENTLY SELECTED range
      final isStart = _selectedStartDate != null && date.year == _selectedStartDate!.year && date.month == _selectedStartDate!.month && date.day == _selectedStartDate!.day;
      final isEnd = _selectedEndDate != null && date.year == _selectedEndDate!.year && date.month == _selectedEndDate!.month && date.day == _selectedEndDate!.day;
      final isInRange = _selectedStartDate != null && _selectedEndDate != null && date.isAfter(_selectedStartDate!) && date.isBefore(_selectedEndDate!);

      // Saved History: A date belongs to history if it's part of a cycle that has ALREADY PASSED
      bool belongsToHistory = false;
      for (var cycle in _savedCycles) {
        final cycleStart = DateTime.parse(cycle['start_date']);
        final cycleEnd = cycle['end_date'] != null 
          ? DateTime.parse(cycle['end_date']) 
          : cycleStart.add(Duration(days: (_periodDuration > 0 ? _periodDuration : 5) - 1));
        
        final bool isCyclePassed = cycleEnd.isBefore(DateTime(now.year, now.month, now.day));
        
        if (isCyclePassed && 
            (date.isAtSameMomentAs(cycleStart) || date.isAfter(cycleStart)) && 
            (date.isAtSameMomentAs(cycleEnd) || date.isBefore(cycleEnd))) {
          belongsToHistory = true;
          break;
        }
      }
      
      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedStartDate = date;
              _selectedEndDate = date.add(Duration(days: _periodDuration - 1));
              
              _editingCycleId = null;
              for (var cycle in _savedCycles) {
                final start = DateTime.parse(cycle['start_date']);
                if (start.year == date.year && start.month == date.month) {
                  _editingCycleId = cycle['id'];
                  break;
                }
              }
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Highlight Saved Cycles (Dark Purple Circle for PASSED cycles)
              if (belongsToHistory)
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCA4FF), // Morado claro for completed periods
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomPaint(
                      painter: StripedPainter(color: Colors.white.withOpacity(0.6)),
                    ),
                  ),
                )
              // 2. Highlight Current Selection or Active Period (Light Purple Range)
              else if (isInRange || isStart || isEnd)
                Container(
                  margin: EdgeInsets.only(
                    left: isStart ? 20 : 0,
                    right: isEnd ? 20 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFFF), // Very light purple
                    borderRadius: BorderRadius.horizontal(
                      left: isStart ? const Radius.circular(20) : Radius.zero,
                      right: isEnd ? const Radius.circular(20) : Radius.zero,
                    ),
                  ),
                ),

              // Number Layer
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (isStart || isEnd) 
                    ? const Color(0xFFEBD8F5) // Main Selection Purple
                    : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$i",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: (isStart || isEnd || isInRange || isToday || belongsToHistory) ? FontWeight.bold : FontWeight.normal,
                    color: (isStart || isEnd || belongsToHistory) 
                      ? Colors.white 
                      : (isToday ? const Color(0xFFFDC5D4) : (isInRange ? const Color(0xFF9C27B0) : Colors.black87)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 0,
      children: dayWidgets,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF8F9).withOpacity(0.0),
            const Color(0xFFFFF8F9).withOpacity(0.9),
            const Color(0xFFFFF8F9),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFBDD4FF).withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : () async {
              if (_selectedStartDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, elige el día del inicio de su período'),
                    backgroundColor: Color(0xFF9C27B0), // Purple for consistent branding
                  ),
                );
                return;
              }

              setState(() => _isLoading = true);
              
              Map<String, dynamic> result;
              if (_editingCycleId != null) {
                result = await HomeService.updateCycle(_editingCycleId!, _selectedStartDate!, endDate: _selectedEndDate);
              } else {
                result = await HomeService.saveCycle(_selectedStartDate!, endDate: _selectedEndDate);
              }

              if (mounted) {
                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registro guardado correctamente'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Refresh data to update circles but stay on screen
                  _loadData();
                } else {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBDD4FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Guardar Inicio de Periodo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class StripedPainter extends CustomPainter {
  final Color color;
  const StripedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    double step = 3.5;
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

