import 'package:flutter/material.dart';
import 'home_service.dart';

class EditPeriodScreen extends StatefulWidget {
  const EditPeriodScreen({super.key});

  @override
  State<EditPeriodScreen> createState() => _EditPeriodScreenState();
}

class _EditPeriodScreenState extends State<EditPeriodScreen> {
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  int _periodDuration = 5;
  bool _isLoading = true;
  bool _selectingStartDate = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final result = await HomeService.getPredictions();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _periodDuration = result['data']['period_duration'] ?? 5;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Only current month and 3 previous months
    final monthsToDisplay = List.generate(4, (index) => DateTime(now.year, now.month - (3 - index)));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEBD8F5)))
          : Stack(
              children: [
                Column(
                  children: [
                    _buildCustomAppBar(),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100), // Extra bottom padding for floating button
                        itemCount: monthsToDisplay.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 30),
                        itemBuilder: (context, index) => _buildMonthCalendar(monthsToDisplay[index]),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildSaveButton(),
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

    List<Widget> dayWidgets = [];
    
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int i = 1; i <= lastDay; i++) {
      final date = DateTime(month.year, month.month, i);
      final isStart = date.year == _selectedStartDate.year && date.month == _selectedStartDate.month && date.day == _selectedStartDate.day;
      final isEnd = _selectedEndDate != null && date.year == _selectedEndDate!.year && date.month == _selectedEndDate!.month && date.day == _selectedEndDate!.day;
      final isInRange = _selectedEndDate != null && date.isAfter(_selectedStartDate) && date.isBefore(_selectedEndDate!);
      
      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              if (_selectingStartDate) {
                _selectedStartDate = date;
                // Auto-selection logic: set end date based on duration
                _selectedEndDate = date.add(Duration(days: _periodDuration - 1));
              } else {
                if (date.isBefore(_selectedStartDate)) {
                  _selectedStartDate = date;
                  _selectedEndDate = date.add(Duration(days: _periodDuration - 1));
                } else {
                  _selectedEndDate = date;
                }
              }
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isInRange || isStart || isEnd)
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
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (isStart || isEnd) 
                    ? const Color(0xFFEBD8F5) // Main purple
                    : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$i",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isStart || isEnd || isInRange ? FontWeight.bold : FontWeight.normal,
                    color: (isStart || isEnd) ? Colors.white : (isInRange ? const Color(0xFF9C27B0) : Colors.black87),
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
      crossAxisSpacing: 0, // 0 spacing to make the range background connect
      children: dayWidgets,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF8F9).withOpacity(0.0),
            const Color(0xFFFFF8F9).withOpacity(0.8),
            const Color(0xFFFFF8F9),
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            final result = await HomeService.saveCycle(_selectedStartDate, endDate: _selectedEndDate);
            if (mounted) {
              setState(() => _isLoading = false);
              if (result['success']) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4E2FF),
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            shadowColor: const Color(0xFFD4E2FF).withOpacity(0.5),
          ),
          child: _isLoading 
            ? const SizedBox(
                height: 20, 
                width: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : const Text('Guardar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

