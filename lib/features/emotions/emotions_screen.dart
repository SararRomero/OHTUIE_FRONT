import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class EmotionsScreen extends StatefulWidget {
  const EmotionsScreen({super.key});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen> with SingleTickerProviderStateMixin {
  bool _isWeekly = true;
  int _selectedIndex = -1;
  int _currentMonthIndex = 2; // Default to March (0-indexed 2)
  int _currentWeekOffset = 0;
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  final List<String> _monthNames = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  ];

  final List<Color> _monthColors = [
    const Color(0xFFBDD4FF), // Blue
    const Color(0xFFEBD8F5), // Purple
    const Color(0xFFFFCCDC), // Pink
    const Color(0xFFC3F0E3), // Mint
  ];

  final List<double> _weeklyData = [0.4, 0.6, 0.5, 0.9, 0.7, 0.3, 0.2];
  final List<double> _monthlyData = [0.5, 0.8, 0.4, 0.7]; // Only 4 weeks

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

  final Map<int, List<String>> _monthlySymptoms = {
    0: ["fatigue", "bloating"],
    1: ["cramps", "fatigue"],
    2: ["normal"],
    3: ["aching_head", "fatigue"],
  };

  final Map<String, Map<String, String>> _symptomLibrary = {
    "aching_head": {
      "msg": "Mi niña, lamento que hoy tu cabecita te moleste. Eres fuerte y esto también pasará.",
      "advice": "Trata de descansar en un lugar oscuro y fresco. Te quiero mucho.",
      "tip": "Evita las pantallas y bebe mucha agua; la hidratación es clave para aliviar la presión.",
      "label": "Dolor de cabeza"
    },
    // ... rest same ...
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
      duration: const Duration(milliseconds: 1200),
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

  void _changeMonth(int delta) {
    setState(() {
      _currentMonthIndex = (_currentMonthIndex + delta) % 12;
      if (_currentMonthIndex < 0) _currentMonthIndex = 11;
      _selectedIndex = -1;
    });
    _chartController.reset();
    _chartController.forward();
  }

  void _changeWeek(int delta) {
    setState(() {
      _currentWeekOffset += delta;
      _selectedIndex = -1;
    });
    _chartController.reset();
    _chartController.forward();
  }

  Color _getPrimaryColor() {
    if (_isWeekly) return const Color(0xFFBDD4FF);
    return _monthColors[_currentMonthIndex % _monthColors.length];
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
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Better balance
                    children: [
                      _buildSelector(),
                      const SizedBox(height: 30),
                      _buildDateRange(),
                      const SizedBox(height: 30),
                      _buildChartContainer(),
                      const SizedBox(height: 30), // Maintain clear distance
                      _buildPredominantEmotionCard(),
                      const SizedBox(height: 30),
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

  Widget _buildPredominantEmotionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBFC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0xFFFDE8E8), blurRadius: 10)
              ]
            ),
            child: const Icon(Icons.favorite, color: Color(0xFFFF5252), size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sentimiento predominante",
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const Text(
                "Tranquilidad y Calma",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
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
              icon: const Icon(Icons.chevron_left, color: Colors.black, size: 26),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFF5F5F5), width: 1.5),
                ),
                elevation: 0,
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
        borderRadius: BorderRadius.circular(30), // Pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated background for the selector
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: _isWeekly ? 0 : (MediaQuery.of(context).size.width - 48 - 8) / 2,
            width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _getPrimaryColor(),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildSelectorButton("Semanal", _isWeekly, () => _toggleView(true)),
              ),
              Expanded(
                child: _buildSelectorButton("Mensual", !_isWeekly, () => _toggleView(false)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : Colors.grey[400],
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRange() {
    String dateText = "";
    if (_isWeekly) {
      // Calculate dynamic week range anchored to a specific date for UI demonstration
      final baseDate = DateTime(2026, 3, 10).add(Duration(days: 7 * _currentWeekOffset));
      final endDate = baseDate.add(const Duration(days: 6));
      final startStr = "${baseDate.day} de ${_monthNames[baseDate.month - 1].substring(0, 3)}";
      final endStr = "${endDate.day} de ${_monthNames[endDate.month - 1].substring(0, 3)}";
      dateText = "$startStr - $endStr, ${baseDate.year}";
    } else {
      dateText = "${_monthNames[_currentMonthIndex]}, 2026";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _isWeekly ? _changeWeek(-1) : _changeMonth(-1),
          icon: Icon(Icons.chevron_left, color: Colors.grey[400], size: 22),
          splashRadius: 24,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                dateText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _isWeekly ? _changeWeek(1) : _changeMonth(1),
          icon: Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          splashRadius: 24,
        ),
      ],
    );
  }

  Widget _buildChartContainer() {
    final primaryColor = _getPrimaryColor();

    return Container(
      constraints: const BoxConstraints(minHeight: 320),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 180,
            child: _isWeekly ? _buildBarChart() : _buildLineChart(),
          ),
          const SizedBox(height: 20),
          if (_selectedIndex != -1)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _isWeekly 
                      ? "Intensidad el ${_getDayName(_selectedIndex)}: ${(_weeklyData[_selectedIndex] * 100).toInt()}%"
                      : "Intensidad Semana ${_selectedIndex + 1}: ${(_monthlyData[_selectedIndex] * 100).toInt()}%",
                    style: TextStyle(color: primaryColor.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Builder(builder: (context) {
                    final index = _selectedIndex;
                    final symptoms = _isWeekly ? _weeklySymptoms[index] : _monthlySymptoms[index];
                    if (symptoms != null) {
                      return Text(
                        "Síntomas: ${symptoms.map((id) => _symptomLibrary[id]?['label'] ?? id).join(', ')}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            )
          else
            Text(
              _isWeekly ? "Toca una barra para ver detalles" : "Toca un punto para ver detalles",
              style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final primaryColor = _getPrimaryColor();

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _weeklyData.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            final isSelected = _selectedIndex == index;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = isSelected ? -1 : index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 32,
                    height: 160 * value * _chartAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isSelected 
                          ? [primaryColor, primaryColor.withOpacity(0.7)]
                          : [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.25)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : [],
                    ),
                    child: isSelected ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                    ) : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ["L", "M", "Mi", "J", "V", "S", "D"][index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? primaryColor : Colors.grey[400],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLineChart() {
    final primaryColor = _getPrimaryColor();

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: LineChartPainter(
                      data: _monthlyData,
                      animationValue: _chartAnimation.value,
                      primaryColor: primaryColor,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                  Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = _selectedIndex == index ? -1 : index),
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox.expand(),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            return Text(
              "Sem ${index + 1}",
              style: TextStyle(
                fontSize: 12,
                color: _selectedIndex == index ? primaryColor : Colors.grey[400],
                fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.w500,
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getDayName(int index) {
    return ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"][index];
  }

  Widget _buildDailyAdviceCard() {
    String symptomId = "normal";
    if (_selectedIndex != -1) {
      final symptoms = _isWeekly ? _weeklySymptoms[_selectedIndex] : _monthlySymptoms[_selectedIndex];
      if (symptoms != null && symptoms.isNotEmpty) symptomId = symptoms.first;
    }
    final symptomData = _symptomLibrary[symptomId] ?? _symptomLibrary["normal"]!;

    return Container(
      width: double.infinity,
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
                  "Consejo del día",
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
    if (_selectedIndex != -1) {
      final symptoms = _isWeekly ? _weeklySymptoms[_selectedIndex] : _monthlySymptoms[_selectedIndex];
      if (symptoms != null && symptoms.isNotEmpty) symptomId = symptoms.first;
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
          width: double.infinity,
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
                "Recuerda que cada emoción es válida y necesaria. Escuchar a tu cuerpo y a tu mente es el acto de amor más grande.",
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
    if (_selectedIndex != -1) {
      final symptoms = _isWeekly ? _weeklySymptoms[_selectedIndex] : _monthlySymptoms[_selectedIndex];
      if (symptoms != null && symptoms.isNotEmpty) symptomId = symptoms.first;
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
          width: double.infinity,
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

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double animationValue;
  final Color primaryColor;
  final int selectedIndex;

  LineChartPainter({
    required this.data,
    required this.animationValue,
    required this.primaryColor,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double padding = 20.0;
    final double graphWidth = size.width - (padding * 2);
    final double graphHeight = size.height - (padding * 2);
    final double stepX = graphWidth / (data.length - 1);

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
        final x = padding + (i * stepX);
        final y = size.height - padding - (data[i] * graphHeight * animationValue);
        points.add(Offset(x, y));
    }

    final Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final cp1 = Offset(p1.dx + (p2.dx - p1.dx) / 3, p1.dy);
      final cp2 = Offset(p1.dx + 2 * (p2.dx - p1.dx) / 3, p2.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp1.dy, p2.dx, p2.dy);
    }

    // Gradient Fill
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, Paint()..shader = ui.Gradient.linear(
      Offset(0, padding), Offset(0, size.height),
      [primaryColor.withOpacity(0.3), Colors.white.withOpacity(0.0)],
    ));

    // Smooth Line
    canvas.drawPath(path, Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round);

    // Points
    for (int i = 0; i < points.length; i++) {
      final isSelected = selectedIndex == i;
      if (isSelected) {
        canvas.drawCircle(points[i], 12, Paint()..color = primaryColor.withOpacity(0.2));
        canvas.drawCircle(points[i], 8, Paint()..color = primaryColor.withOpacity(0.1));
      }
      canvas.drawCircle(points[i], 6, Paint()..color = primaryColor);
      canvas.drawCircle(points[i], 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => true;
}
