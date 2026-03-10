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
    {'id': 'aching_head', 'label': 'Dolor de cabeza', 'imagePath': 'lib/assets/image/dolor_de_cabeza.png'},
    {'id': 'add_weight', 'label': 'Aumento de peso', 'imagePath': 'lib/assets/image/peso.png'},
    {'id': 'cramps', 'label': 'Cólicos', 'imagePath': 'lib/assets/image/colicos.png'},
    {'id': 'bloating', 'label': 'Hinchazón', 'imagePath': 'lib/assets/image/hinchazon.png'},
    {'id': 'fatigue', 'label': 'Fatiga', 'imagePath': 'lib/assets/image/fatiga.png'},
  ];

  final List<Map<String, String>> _moodOptions = [
    {'id': 'normal', 'label': 'Normal', 'imagePath': 'lib/assets/image/normal.png'},
    {'id': 'angry', 'label': 'Enojada', 'imagePath': 'lib/assets/image/enojada.png'},
    {'id': 'happy', 'label': 'Feliz', 'imagePath': 'lib/assets/image/feliz.png'},
    {'id': 'sad', 'label': 'Triste', 'imagePath': 'lib/assets/image/triste.png'},
    {'id': 'calm', 'label': 'Tranquila', 'imagePath': 'lib/assets/image/tranquila.png'},
    {'id': 'tired', 'label': 'Cansada', 'imagePath': 'lib/assets/image/cansada.png'},
  ];

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
          child: Column(
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
                    _buildFlowSelector(),
                    const SizedBox(height: 30),
                    _buildSectionTitle("Síntomas"),
                    const SizedBox(height: 16),
                    _buildSymptomGrid(),
                    const SizedBox(height: 30),
                    _buildSectionTitle("Estados de ánimo"),
                    const SizedBox(height: 16),
                    _buildMoodGrid(),
                    const SizedBox(height: 40),
                  ],
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
                color: Color(0xFFFFB2C1), // Darker pink icon bg
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

  Widget _buildFlowSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2; // 2 items per row, 12 spacing
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _flowOptions.entries.map((entry) {
            final isSelected = _selectedFlow == entry.key;
            
            Widget iconWidget;
            if (entry.key == 'none') {
              iconWidget = Stack(
                alignment: Alignment.center,
                children: [
                   const Icon(Icons.water_drop, color: Colors.white, size: 20),
                   Transform.rotate(
                     angle: -0.785, // -45 degrees
                     child: Container(width: 2, height: 24, color: const Color(0xFFFFB2C1)),
                   ),
                ],
              );
            } else if (entry.key == 'light') {
              iconWidget = const Icon(Icons.water_drop, color: Colors.white, size: 20);
            } else if (entry.key == 'medium') {
              iconWidget = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.water_drop, color: Colors.white, size: 16),
                   Icon(Icons.water_drop, color: Colors.white, size: 20),
                ],
              );
            } else {
              iconWidget = Stack(
                alignment: Alignment.center,
                children: [
                   const Padding(
                     padding: EdgeInsets.only(bottom: 8),
                     child: Icon(Icons.water_drop, color: Colors.white, size: 16),
                   ),
                   const Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(Icons.water_drop, color: Colors.white, size: 16),
                       SizedBox(width: 2),
                       Icon(Icons.water_drop, color: Colors.white, size: 16),
                     ],
                   ),
                ],
              );
            }

            return GestureDetector(
              onTap: () => setState(() => _selectedFlow = entry.key),
              child: Container(
                width: itemWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected ? Border.all(color: const Color(0xFFFF4081), width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8FA3), // Pink circle
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: iconWidget),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSymptomGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _symptomOptions.map((s) {
            final isSelected = _selectedSymptoms.contains(s['id']);
            return GestureDetector(
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
                width: itemWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected ? Border.all(color: const Color(0xFFFF4081), width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
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
                    Image.asset(
                      s['imagePath']!,
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMoodGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _moodOptions.map((m) {
            final isSelected = _selectedMoods.contains(m['id']);
            return GestureDetector(
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
                width: itemWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected ? Border.all(color: const Color(0xFFFF4081), width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
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
                    Image.asset(
                      m['imagePath']!,
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withAlpha(80),
              blurRadius: 15,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blue.withAlpha(150), width: 1.5),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveLog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF90CAF9), // Pastel blue
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
