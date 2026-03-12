import 'package:flutter/material.dart';

class EmotionsScreen extends StatefulWidget {
  const EmotionsScreen({super.key});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen> with SingleTickerProviderStateMixin {
  bool _isWeekly = true;
  int _selectedIndex = -1;
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  final List<double> _weeklyData = [0.4, 0.6, 0.5, 0.9, 0.7, 0.3, 0.2];
  final List<double> _monthlyData = [0.5, 0.7, 0.4, 0.8, 0.6, 0.9, 0.7, 0.5];

  // Mocked symptoms for each data point
  final Map<int, List<String>> _weeklySymptoms = {
    0: ["fatigue"],
    1: ["aching_head"],
    2: ["bloating"],
    3: ["cramps", "aching_head"],
    4: ["fatigue"],
    5: ["add_weight"],
    6: ["normal"],
  };

  final Map<String, Map<String, String>> _symptomLibrary = {
    "aching_head": {
      "msg": "Mi niña, lamento que hoy tu cabecita te moleste. Eres fuerte y esto también pasará.",
      "advice": "Trata de descansar en un lugar oscuro y fresco. Te quiero mucho.",
      "tip": "Evita las pantallas y bebe mucha agua; la hidratación es clave para aliviar la presión.",
      "label": "Dolor de cabeza"
    },
    "add_weight": {
      "msg": "Hermosa, tu cuerpo es perfecto tal como es. Estas variaciones son normales y no definen tu luz.",
      "advice": "No seas dura contigo misma, abrázate hoy con mucha compasión.",
      "tip": "La retención de líquidos es común; prueba infusiones de jengibre para sentirte más ligera.",
      "label": "Aumento de peso"
    },
    "cramps": {
      "msg": "Sé que esos cólicos son difíciles, bonita. Estoy aquí mandándote todo mi amor para que te sientas mejor.",
      "advice": "Una compresa tibia en tu vientre te dará ese apapacho que necesitas ahora.",
      "tip": "Estiramientos suaves de yoga pueden ayudar a relajar los músculos del útero.",
      "label": "Cólicos"
    },
    "bloating": {
      "msg": "Sentirse hinchada es incómodo, pero recuerda que es solo tu cuerpo procesando sus ciclos naturales.",
      "advice": "Usa ropa cómoda que te haga sentir libre y sin presiones.",
      "tip": "Evita la sal estos días; opta por alimentos ricos en potasio como el plátano.",
      "label": "Hinchazón"
    },
    "fatigue": {
      "msg": "Si hoy te sientes sin fuerzas, está bien descansar. No tienes que poder con todo siempre, valiente.",
      "advice": "Permítete una siesta corta, tu cuerpo te lo está pidiendo con amor.",
      "tip": "El magnesio y dormir 8 horas completas harán maravillas por tu energía mañana.",
      "label": "Fatiga"
    },
    "normal": {
      "msg": "Cada emoción es un mensaje de tu corazón, bonita. Escúchala con amor y paciencia.",
      "advice": "Sigue cuidándote así de bien, te lo mereces todo.",
      "tip": "Mantén tu rutina de autocuidado, ¡lo estás haciendo genial!",
      "label": "Tranquila"
    }
  };

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutQuart,
    );
    _chartController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  void _toggleView(bool weekly) {
    if (_isWeekly != weekly) {
      setState(() {
        _isWeekly = weekly;
        _selectedIndex = -1;
      });
      _chartController.reset();
      _chartController.forward();
    }
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
            colors: [Color(0xFFF0F5FF), Color(0xFFFCF0F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSelector(),
                      const SizedBox(height: 30),
                      _buildDateRange(),
                      const SizedBox(height: 30),
                      _buildChartContainer(),
                      const SizedBox(height: 40),
                      _buildDailyAdviceCard(),
                      const SizedBox(height: 30),
                      _buildAdviceCard(),
                      const SizedBox(height: 30),
                      _buildHealthyTipsCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
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
            "Emociones",
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

  Widget _buildSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorButton("Semanal", _isWeekly, () => _toggleView(true)),
          ),
          Expanded(
            child: _buildSelectorButton("Mensual", !_isWeekly, () => _toggleView(false)),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? (_isWeekly ? const Color(0xFFBDD4FF) : const Color(0xFFEBD8F5)) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.chevron_left, color: Colors.grey[400]),
        const SizedBox(width: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
              ),
            ],
          ),
          child: Text(
            _isWeekly ? "10 de Mar - 16 de Mar, 2026" : "Marzo, 2026",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildChartContainer() {
    final data = _isWeekly ? _weeklyData : _monthlyData;
    final primaryColor = _isWeekly ? const Color(0xFFBDD4FF) : const Color(0xFFEBD8F5);
    final secondaryColor = _isWeekly ? const Color(0xFFE0E9FF) : const Color(0xFFF5EAFC);

    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value;
                    final isSelected = _selectedIndex == index;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = isSelected ? -1 : index;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${(value * 100).toInt()}%",
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            width: 28,
                            height: 160 * value * _chartAnimation.value,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isSelected 
                                  ? [primaryColor, secondaryColor]
                                  : [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.3)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ] : [],
                            ),
                            child: isSelected ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ) : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isWeekly ? ["L", "M", "Mi", "J", "V", "S", "D"][index] : "S${index + 1}",
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? primaryColor : Colors.grey[400],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          if (_selectedIndex != -1)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  Text(
                    _isWeekly 
                      ? "Intensidad el ${_getDayName(_selectedIndex)}: ${(_weeklyData[_selectedIndex] * 100).toInt()}%"
                      : "Intensidad Semana ${_selectedIndex + 1}: ${(_monthlyData[_selectedIndex] * 100).toInt()}%",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  if (_isWeekly && _weeklySymptoms.containsKey(_selectedIndex))
                    Text(
                      "Síntomas registrados: ${_weeklySymptoms[_selectedIndex]!.map((id) => _symptomLibrary[id]?['label'] ?? id).join(', ')}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getDayName(int index) {
    return ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"][index];
  }

  Widget _buildDailyAdviceCard() {
    String symptomId = "normal";
    if (_selectedIndex != -1 && _isWeekly && _weeklySymptoms.containsKey(_selectedIndex)) {
       symptomId = _weeklySymptoms[_selectedIndex]!.first;
    }
    
    final symptomData = _symptomLibrary[symptomId] ?? _symptomLibrary["normal"]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB2C1), Color(0xFFFF85A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB2C1).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Consejo de bienestar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  symptomData["advice"]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    String symptomId = "normal";
    if (_selectedIndex != -1 && _isWeekly && _weeklySymptoms.containsKey(_selectedIndex)) {
       symptomId = _weeklySymptoms[_selectedIndex]!.first;
    }
    
    final symptomData = _symptomLibrary[symptomId] ?? _symptomLibrary["normal"]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Acerca de tus emociones",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¡Hola, bonita!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                symptomData["msg"]!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Recuerda que cada emoción es válida y necesaria. Escuchar a tu cuerpo y a tu mente es el acto de amor más grande que puedes hacer por ti. Sigue cuidándote así de bien, ¡te lo mereces todo!",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[500],
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthyTipsCard() {
    String symptomId = "normal";
    if (_selectedIndex != -1 && _isWeekly && _weeklySymptoms.containsKey(_selectedIndex)) {
       symptomId = _weeklySymptoms[_selectedIndex]!.first;
    }
    
    final symptomData = _symptomLibrary[symptomId] ?? _symptomLibrary["normal"]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tips Saludables",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFBDD4FF).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFFBDD4FF), size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  symptomData["tip"]!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
