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
    final monthsToDisplay = List.generate(12, (index) => DateTime(now.year, index + 1));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edita tu periodo',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFEBD8F5)))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildStepIndicator("Inicio", _selectingStartDate, () => setState(() => _selectingStartDate = true)),
                    const SizedBox(width: 12),
                    _buildStepIndicator("Fin (Opcional)", !_selectingStartDate, () => setState(() => _selectingStartDate = false)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
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

  Widget _buildStepIndicator(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFB2C1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFB2C1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFFFB2C1),
            fontWeight: FontWeight.bold,
          ),
        ),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
      children: days.map((d) => Text(d, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 14))).toList(),
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
                // Auto-clear end date if it's before new start date
                if (_selectedEndDate != null && _selectedEndDate!.isBefore(_selectedStartDate)) {
                  _selectedEndDate = null;
                }
              } else {
                if (date.isBefore(_selectedStartDate)) {
                  _selectedStartDate = date;
                  _selectedEndDate = null;
                  _selectingStartDate = false;
                } else {
                  _selectedEndDate = date;
                }
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (isStart || isEnd) 
                ? const Color(0xFFFFB2C1) 
                : (isInRange ? const Color(0xFFFFF0F3) : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Text(
              "$i",
              style: TextStyle(
                fontWeight: isStart || isEnd || isInRange ? FontWeight.bold : FontWeight.normal,
                color: (isStart || isEnd) ? Colors.white : (isInRange ? const Color(0xFFFF4081) : Colors.black87),
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
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: dayWidgets,
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
            backgroundColor: const Color(0xFFFFCCE5),
            foregroundColor: const Color(0xFFFF4081),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading 
            ? const SizedBox(
                height: 20, 
                width: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : const Text('Actualizar Periodo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

