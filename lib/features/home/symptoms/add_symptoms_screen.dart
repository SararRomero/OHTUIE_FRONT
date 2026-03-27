import 'package:flutter/material.dart';
import 'daily_log_service.dart';
import '../../../core/widgets/cycle_loading_button.dart';
import 'widgets/flow_selector_widget.dart';
import 'widgets/symptom_selector_widget.dart';
import 'widgets/mood_selector_widget.dart';

class AddSymptomsScreen extends StatefulWidget {
  const AddSymptomsScreen({super.key});

  @override
  State<AddSymptomsScreen> createState() => _AddSymptomsScreenState();
}

class _AddSymptomsScreenState extends State<AddSymptomsScreen> {
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  String? _selectedFlow;
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedMoods = [];

  @override
  void initState() {
    super.initState();
    _loadLogForDate(_selectedDate);
  }

  Future<void> _loadLogForDate(DateTime date) async {
    setState(() {
      _selectedFlow = null;
      _selectedSymptoms.clear();
      _selectedMoods.clear();
    });
    
    final result = await DailyLogService.getDailyLog(date);
    if (mounted && result['success'] && result['data'] != null) {
      final data = result['data'];
      setState(() {
        _selectedFlow = data['flow'];
        _selectedSymptoms.addAll(List<String>.from(data['symptoms'] ?? []));
        _selectedMoods.addAll(List<String>.from(data['moods'] ?? []));
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEBD8F5),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF4081),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadLogForDate(_selectedDate);
    }
  }

  String _formatDate(DateTime date) {
    const months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];
    const weekdays = ["lun", "mar", "mié", "jue", "vie", "sáb", "dom"];
    return "${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}";
  }

  Future<void> _saveLog() async {
    setState(() => _isLoading = true);
    final data = {
      'date': _selectedDate.toIso8601String().split('T')[0],
      'flow': _selectedFlow ?? 'none',
      'symptoms': _selectedSymptoms,
      'moods': _selectedMoods,
    };
    final result = await DailyLogService.saveDailyLog(data);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8F9), Color(0xFFFFE5E9)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 10),
                        Center(child: _buildDateSelector()),
                        const SizedBox(height: 30),
                        _buildSectionTitle("Flujo"),
                        const SizedBox(height: 16),
                        FlowSelectorWidget(
                          selectedFlow: _selectedFlow,
                          onChanged: (val) => setState(() => _selectedFlow = val),
                        ),
                        const SizedBox(height: 30),
                        _buildSectionTitle("Síntomas"),
                        const SizedBox(height: 16),
                        SymptomSelectorWidget(
                          selectedSymptoms: _selectedSymptoms,
                          onToggle: (id, selected) {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.add(id);
                              } else {
                                _selectedSymptoms.remove(id);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildSectionTitle("Estados de ánimo"),
                        const SizedBox(height: 16),
                        MoodSelectorWidget(
                          selectedMoods: _selectedMoods,
                          onToggle: (id, selected) {
                            setState(() {
                              if (selected) {
                                _selectedMoods.add(id);
                              } else {
                                _selectedMoods.remove(id);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 100), // Space for floating button
                      ],
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
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
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
          ),
          const Text(
            "Registro de tus sintomas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5E9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFB2C1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
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
      child: Center(
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFBDD4FF).withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: const Color(0xFFBDD4FF).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: CycleLoadingButton(
            text: 'Guardar',
            isLoading: _isLoading,
            onPressed: _saveLog,
            backgroundColor: const Color(0xFFBDD4FF),
            borderRadius: 30,
            height: 60,
          ),
        ),
      ),
    );
  }
}