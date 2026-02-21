import 'package:flutter/material.dart';
import 'home_service.dart';

class EditPeriodScreen extends StatefulWidget {
  const EditPeriodScreen({super.key});

  @override
  State<EditPeriodScreen> createState() => _EditPeriodScreenState();
}

class _EditPeriodScreenState extends State<EditPeriodScreen> {
  DateTime _selectedDate = DateTime.now();
  int _periodDuration = 5;
  bool _isLoading = true;
  
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
    final monthsToDisplay = List.generate(12, (index) => DateTime(now.year, index + 1));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        title: const Text('Edita tu periodo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: monthsToDisplay.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 30),
                  itemBuilder: (context, index) => _buildMonthCalendar(monthsToDisplay[index]),
                ),
              ),
              _buildSaveButton(),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                yearMonthStr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Row(
                children: [
                  Icon(Icons.chevron_left, color: Colors.grey),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeekdayHeader(),
          const SizedBox(height: 10),
          _buildDaysGrid(month),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final days = ['D', 'L', 'M', 'M', 'J', 'V', 'S']; // Sunday to Saturday in Spanish
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((d) => Text(d, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))).toList(),
    );
  }

  Widget _buildDaysGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final startingWeekday = firstDay.weekday % 7; // Convert to 0=Sun, 1=Mon...

    List<Widget> dayWidgets = [];
    
    // Empty spaces for previous month
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Actual days
    for (int i = 1; i <= lastDay; i++) {
      final date = DateTime(month.year, month.month, i);
      final isSelected = _isInRange(date);
      final isStart = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
      
      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFE5E9) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              "$i",
              style: TextStyle(
                fontWeight: isStart || isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFFF4081) : Colors.black,
              ),
            ),
          ),
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

  bool _isInRange(DateTime date) {
    final diff = date.difference(_selectedDate).inDays;
    return diff >= 0 && diff < _periodDuration;
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () async {
            setState(() => _isLoading = true);
            final result = await HomeService.saveCycle(_selectedDate);
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
            backgroundColor: const Color(0xFFBFD4FF), // Blue
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Text('Guardar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
