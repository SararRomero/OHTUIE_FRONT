import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../profile/user_service.dart';

class EditCycleScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const EditCycleScreen({super.key, this.initialData});

  @override
  State<EditCycleScreen> createState() => _EditCycleScreenState();
}

class _EditCycleScreenState extends State<EditCycleScreen> with SingleTickerProviderStateMixin {
  // 0 = ninguna, 1 = último periodo, 2 = duración del periodo, 3 = duración del ciclo
  int _expandedSection = 0;
  bool _isSaving = false;

  DateTime _lastPeriodDate = DateTime.now();
  int _periodDuration = 5;
  int _cycleDuration = 28;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      if (widget.initialData!['last_period_start'] != null) {
        _lastPeriodDate = DateTime.parse(widget.initialData!['last_period_start']);
      } else if (widget.initialData!['last_period'] != null) {
        _lastPeriodDate = DateTime.parse(widget.initialData!['last_period']);
      }
      _periodDuration = widget.initialData!['period_duration'] ?? 5;
      _cycleDuration = widget.initialData!['avg_cycle_duration'] ?? widget.initialData!['cycle_duration'] ?? 28;
    }
  }

  void _toggleSection(int section) {
    setState(() {
      _expandedSection = _expandedSection == section ? 0 : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F5FF), // Azul pastel muy claro
              Color(0xFFFCF0F5), // Rosa pastel muy claro
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                      child: Column(
                        children: [
                          _buildInfoSection(),
                          const SizedBox(height: 24),
                          _buildLastPeriodSection(),
                          const SizedBox(height: 16),
                          _buildPeriodDurationSection(),
                          const SizedBox(height: 16),
                          _buildCycleDurationSection(),
                          const SizedBox(height: 50),
                          _buildSaveButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    if (_isSaving)
                      Container(
                        color: Colors.white.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFFFF4081)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.close_rounded, color: Colors.black87),
              ),
            ),
          ),
          const Text(
            "Cambia tu información",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB2C1).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFFFF4081), size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "Ajusta tus datos para que tus predicciones sean mucho más precisas.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget expandedContent,
    required Color accentColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isExpanded ? accentColor.withOpacity(0.12) : Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isExpanded ? accentColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isExpanded ? accentColor : Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isExpanded ? accentColor : Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(height: 1, color: accentColor.withOpacity(0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: expandedContent,
                  ),
                ],
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 350),
              sizeCurve: Curves.easeInOutExpo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPeriodSection() {
    final List<String> months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final List<int> years = List.generate(11, (i) => DateTime.now().year - 5 + i);

    return _buildCard(
      title: "¿Cuándo fue tu último periodo?",
      isExpanded: _expandedSection == 1,
      accentColor: const Color(0xFF93C5FD), // Azul destacado
      onTap: () => _toggleSection(1),
      expandedContent: Column(
        children: [
          const Text(
            "Selecciona la fecha de inicio",
            style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Día
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: _lastPeriodDate.day - 1),
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _lastPeriodDate = DateTime(
                          _lastPeriodDate.year,
                          _lastPeriodDate.month,
                          index + 1,
                        );
                      });
                    },
                    children: List.generate(31, (i) => Center(
                      child: Text("${i + 1}", style: const TextStyle(fontSize: 18)),
                    )),
                  ),
                ),
                // Mes (Abreviado)
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: _lastPeriodDate.month - 1),
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _lastPeriodDate = DateTime(
                          _lastPeriodDate.year,
                          index + 1,
                          _lastPeriodDate.day,
                        );
                      });
                    },
                    children: months.map((m) => Center(
                      child: Text(m, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ),
                // Año
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: years.indexOf(_lastPeriodDate.year) != -1 
                          ? years.indexOf(_lastPeriodDate.year) 
                          : 5
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _lastPeriodDate = DateTime(
                          years[index],
                          _lastPeriodDate.month,
                          _lastPeriodDate.day,
                        );
                      });
                    },
                    children: years.map((y) => Center(
                      child: Text("$y", style: const TextStyle(fontSize: 18)),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDurationSection() {
    return _buildCard(
      title: "¿Cuánto dura tu periodo?",
      isExpanded: _expandedSection == 2,
      accentColor: const Color(0xFFFF9EAF), // Rosa destacado
      onTap: () => _toggleSection(2),
      expandedContent: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 160,
                child: CupertinoPicker(
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(initialItem: _periodDuration - 1),
                  onSelectedItemChanged: (int index) {
                    setState(() => _periodDuration = index + 1);
                  },
                  children: List<Widget>.generate(15, (int index) {
                    final isSelected = _periodDuration == (index + 1);
                    return Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: isSelected ? 30 : 22,
                          color: isSelected ? const Color(0xFFFF4081) : Colors.black12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "días",
                style: TextStyle(
                  color: Color(0xFFFFB2C1),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleDurationSection() {
    return _buildCard(
      title: "¿Cuánto dura tu ciclo?",
      isExpanded: _expandedSection == 3,
      accentColor: const Color(0xFFA78BFA), // Violeta destacado
      onTap: () => _toggleSection(3),
      expandedContent: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 160,
                child: CupertinoPicker(
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(initialItem: _cycleDuration - 15),
                  onSelectedItemChanged: (int index) {
                    setState(() => _cycleDuration = index + 15);
                  },
                  children: List<Widget>.generate(31, (int index) {
                    int value = index + 15;
                    final isSelected = _cycleDuration == value;
                    return Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: isSelected ? 30 : 22,
                          color: isSelected ? const Color(0xFFA78BFA) : Colors.black12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "días",
                style: TextStyle(
                  color: Color(0xFFA78BFA),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB2C1), Color(0xFFFF4081)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4081).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : () async {
          setState(() => _isSaving = true);
          
          final result = await UserService.updateUserMe(
            cycleDuration: _cycleDuration,
            periodDuration: _periodDuration,
            lastPeriodDate: _lastPeriodDate.toIso8601String().split('T')[0],
          );

          if (mounted) {
            setState(() => _isSaving = false);
            if (result['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Configuración de ciclo actualizada")),
              );
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'])),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleActionShape(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          "Guardar cambios",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class RoundedRectangleActionShape extends RoundedRectangleBorder {
  const RoundedRectangleActionShape({super.borderRadius});
}

