import 'package:flutter/material.dart';
import 'daily_log_service.dart';

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

  // Options
  final Map<String, String> _flowOptions = {
    'none': 'Ninguno',
    'light': 'Bajo',
    'medium': 'Normal',
    'heavy': 'Alto',
  };

  final List<Map<String, String>> _symptomOptions = [
    {'id': 'aching_head', 'label': 'Dolor de Cabeza', 'icon': '頭'},
    {'id': 'add_weight', 'label': 'Aumento Peso', 'icon': '⚖️'},
    {'id': 'cramps', 'label': 'Cólicos', 'icon': '⚡'},
    {'id': 'bloating', 'label': 'Hinchazón', 'icon': '🎈'},
  ];

  final List<Map<String, String>> _moodOptions = [
    {'id': 'calm', 'label': 'Tranquila', 'icon': '😌'},
    {'id': 'angry', 'label': 'Enojada', 'icon': '😡'},
    {'id': 'happy', 'label': 'Feliz', 'icon': '😃'},
    {'id': 'sad', 'label': 'Triste', 'icon': '😢'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLogForDate(_selectedDate);
  }

  Future<void> _loadLogForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
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
    if (mounted) setState(() => _isLoading = false);
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFEBD8F5)))
                  : SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height - 180, // Approximate height minus header/footer
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _buildDateSelector(),
                            const SizedBox(height: 30),
                            _buildSectionTitle("Flujo"),
                            const SizedBox(height: 20),
                            _buildFlowSelector(),
                            const Spacer(),
                            _buildSectionTitle("Síntomas", showArrow: true),
                            const SizedBox(height: 20),
                            _buildSymptomGrid(),
                            const Spacer(),
                            _buildSectionTitle("Estados de ánimo", showArrow: true),
                            const SizedBox(height: 20),
                            _buildMoodGrid(),
                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
              ),
              _buildSaveButton(),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE).withAlpha(150),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          _formatDate(_selectedDate),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showArrow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (showArrow)
          const Icon(Icons.chevron_right, color: Colors.black54),
      ],
    );
  }

  Widget _buildFlowSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _flowOptions.entries.map((entry) {
          final isSelected = _selectedFlow == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFlow = entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected 
                      ? Border.all(color: const Color(0xFFFF4081), width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 18,
                      color: isSelected ? const Color(0xFFFF4081) : const Color(0xFFFFB2C1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFFF4081) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSymptomGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _symptomOptions.map((s) {
          final isSelected = _selectedSymptoms.contains(s['id']);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSymptoms.remove(s['id']);
                  } else {
                    _selectedSymptoms.add(s['id']!);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: isSelected 
                      ? Border.all(color: const Color(0xFFFF4081), width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(s['icon']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      s['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFFF4081) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMoodGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _moodOptions.map((m) {
          final isSelected = _selectedMoods.contains(m['id']);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedMoods.remove(m['id']);
                  } else {
                    _selectedMoods.add(m['id']!);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: isSelected 
                      ? Border.all(color: const Color(0xFFFF4081), width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(m['icon']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      m['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFFF4081) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveLog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEBD8F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Guardar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        ),
      ),
    );
  }
}
