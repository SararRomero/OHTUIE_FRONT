import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../home/symptoms/daily_log_service.dart';
import 'package:intl/intl.dart';

class EmotionsScreen extends StatefulWidget {
  const EmotionsScreen({super.key});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen> with SingleTickerProviderStateMixin {
  bool _isWeekly = true;
  int _selectedIndex = -1;
  late int _currentMonthIndex;
  int _currentWeekOffset = 0;
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  // Real Data
  bool _isLoading = true;
  Map<String, dynamic> _moodLibrary = {};
  Map<String, dynamic> _stats = {
    "predominant": "normal",
    "daily": []
  };

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

  @override
  void initState() {
    super.initState();
    _currentMonthIndex = DateTime.now().month - 1;
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutQuart,
    );
    
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    final libResult = await DailyLogService.getMoodLibrary();
    if (libResult['success']) {
      _moodLibrary = libResult['data'];
    }
    await _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    DateTime start, end;
    if (_isWeekly) {
      // Current week range
      final now = DateTime.now();
      final baseDate = now.add(Duration(days: 7 * _currentWeekOffset));
      start = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      end = start.add(const Duration(days: 6));
    } else {
      // Current month range
      final year = DateTime.now().year;
      start = DateTime(year, _currentMonthIndex + 1, 1);
      end = DateTime(year, _currentMonthIndex + 2, 0); // Last day of month
    }

    final statsResult = await DailyLogService.getMoodStats(start, end);
    if (mounted) {
      setState(() {
        if (statsResult['success']) {
          _stats = statsResult['data'];
        }
        _isLoading = false;
        _selectedIndex = -1;
      });
      _chartController.reset();
      _chartController.forward();
    }
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
      });
      _loadStats();
    }
  }

  void _changeMonth(int delta) {
    int newIndex = _currentMonthIndex + delta;
    if (newIndex >= 0 && newIndex < DateTime.now().month) {
      setState(() {
        _currentMonthIndex = newIndex;
      });
      _loadStats();
    }
  }

  void _changeWeek(int delta) {
    int newOffset = _currentWeekOffset + delta;
    final now = DateTime.now();
    // Cannot go to future weeks (offset > 0)
    if (newOffset > 0) return;

    // Check if new week is in current year
    final baseDate = now.add(Duration(days: 7 * newOffset));
    final start = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    
    if (start.year == now.year) {
      setState(() {
        _currentWeekOffset = newOffset;
      });
      _loadStats();
    }
  }

  bool get _canMoveNextMonth => _currentMonthIndex < DateTime.now().month - 1;
  bool get _canMovePrevMonth => _currentMonthIndex > 0;
  
  bool get _canMoveNextWeek => _currentWeekOffset < 0;
  bool get _canMovePrevWeek {
    final now = DateTime.now();
    final baseDate = now.add(Duration(days: 7 * (_currentWeekOffset - 1)));
    final start = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    return start.year == now.year;
  }

  Color _getPrimaryColor() {
    if (_isWeekly) return const Color(0xFFBDD4FF);
    return _monthColors[_currentMonthIndex % _monthColors.length];
  }

  bool get _hasData {
    final List<dynamic> daily = _stats['daily'] ?? [];
    return daily.any((day) => (day['moods'] as List).isNotEmpty);
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
                child: RefreshIndicator(
                  onRefresh: _loadStats,
                  color: const Color(0xFFFF85A1),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildSelector(),
                        const SizedBox(height: 30),
                        _buildDateRange(),
                        const SizedBox(height: 30),
                        _buildChartContainer(),
                        if (_hasData) ...[
                          const SizedBox(height: 30),
                          _buildPredominantEmotionCard(),
                          const SizedBox(height: 30),
                          _buildDailyAdviceCard(),
                          const SizedBox(height: 30),
                          _buildAdviceCard(),
                          const SizedBox(height: 30),
                          _buildHealthyTipsCard(),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
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
    final predKey = _stats['predominant'] ?? 'normal';
    final moodData = _moodLibrary[predKey] ?? {'label': 'Tranquila', 'icon': 'favorite'};
    
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
                "Sentimiento destacado",
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              Text(
                moodData['label'] ?? "Tranquilidad y Calma",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'headset_off': return Icons.headset_off;
      case 'monitor_weight': return Icons.monitor_weight_outlined;
      case 'water_drop': return Icons.water_drop_rounded;
      case 'bubble_chart': return Icons.bubble_chart_outlined;
      case 'battery_low': return Icons.battery_charging_full_rounded;
      case 'sentiment_very_satisfied': return Icons.sentiment_very_satisfied;
      case 'sentiment_very_dissatisfied': return Icons.sentiment_very_dissatisfied;
      case 'self_improvement': return Icons.self_improvement;
      case 'check_circle': return Icons.check_circle_outline;
      default: return Icons.favorite;
    }
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
        borderRadius: BorderRadius.circular(30),
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
      final now = DateTime.now();
      final baseDate = now.add(Duration(days: 7 * _currentWeekOffset));
      final start = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      
      final startStr = DateFormat('d MMM', 'es').format(start);
      final endStr = DateFormat('d MMM', 'es').format(end);
      dateText = "$startStr - $endStr, ${start.year}";
    } else {
      dateText = "${_monthNames[_currentMonthIndex]}, ${DateTime.now().year}";
    }

    final bool canPrev = _isWeekly ? _canMovePrevWeek : _canMovePrevMonth;
    final bool canNext = _isWeekly ? _canMoveNextWeek : _canMoveNextMonth;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: canPrev ? () => _isWeekly ? _changeWeek(-1) : _changeMonth(-1) : null,
          icon: Icon(Icons.chevron_left, color: canPrev ? Colors.grey[400] : Colors.grey[200], size: 22),
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
          onPressed: canNext ? () => _isWeekly ? _changeWeek(1) : _changeMonth(1) : null,
          icon: Icon(Icons.chevron_right, color: canNext ? Colors.grey[400] : Colors.grey[200], size: 22),
          splashRadius: 24,
        ),
      ],
    );
  }

  Widget _buildChartContainer() {
    final primaryColor = _getPrimaryColor();
    final List<dynamic> dailyData = _stats['daily'] ?? [];

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
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF85A1)))
              : (_isWeekly ? _buildBarChart(dailyData) : _buildLineChart(dailyData)),
          ),
          const SizedBox(height: 20),
          if (_selectedIndex != -1 && dailyData.isNotEmpty && _selectedIndex < dailyData.length)
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
                      ? "Intensidad el ${_getDayName(dailyData[_selectedIndex]['date'])}: ${(dailyData[_selectedIndex]['intensity'] * 100).toInt()}%"
                      : "Semana ${_selectedIndex + 1}: ${(dailyData[_selectedIndex]['intensity'] * 100).toInt()}%",
                    style: TextStyle(color: primaryColor.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Builder(builder: (context) {
                    final List moods = dailyData[_selectedIndex]['moods'] ?? [];
                    if (moods.isNotEmpty) {
                      return Text(
                        "Ánimos: ${moods.map((m) => _moodLibrary[m]?['label'] ?? m).join(', ')}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                      );
                    }
                    return const Text("Sin registros este día", style: TextStyle(fontSize: 12, color: Colors.grey));
                  }),
                ],
              ),
            )
          else if (!_isLoading)
            Text(
              _isWeekly ? "Toca una barra para ver detalles" : "Toca un punto para ver detalles",
              style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  String _getDayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE', 'es').format(date);
    } catch (_) {
      return "Día";
    }
  }

  Widget _buildBarChart(List<dynamic> dailyData) {
    final primaryColor = _getPrimaryColor();
    // In weekly mode, we expect exactly 7 days. If not, we pad
    List<double> values = List.generate(7, (i) => 0.0);
    for (var i = 0; i < dailyData.length && i < 7; i++) {
       values[i] = (dailyData[i]['intensity'] as num).toDouble();
    }

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: values.asMap().entries.map((entry) {
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
                    height: (160 * value * _chartAnimation.value).clamp(4.0, 160.0),
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

  Widget _buildLineChart(List<dynamic> dailyData) {
    final primaryColor = _getPrimaryColor();
    // In monthly mode, dailyData might be long. We compress it into 4 points (weeks)
    // For now, let's just take the first 4 if they exist, or average them.
    List<double> points = [0.1, 0.1, 0.1, 0.1];
    if (dailyData.isNotEmpty) {
       int chunkSize = (dailyData.length / 4).ceil();
       for (int i = 0; i < 4; i++) {
          int start = i * chunkSize;
          int end = (i + 1) * chunkSize;
          if (start < dailyData.length) {
             double sum = 0;
             int count = 0;
             for (int j = start; j < end && j < dailyData.length; j++) {
                sum += (dailyData[j]['intensity'] as num).toDouble();
                count++;
             }
             points[i] = sum / count;
          }
       }
    }

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
                      data: points,
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

  Map<String, dynamic> _getSelectedMoodData() {
    String moodKey = _stats['predominant'] ?? 'normal';
    final List<dynamic> daily = _stats['daily'] ?? [];
    
    if (_selectedIndex != -1 && daily.isNotEmpty) {
      if (_isWeekly && _selectedIndex < daily.length) {
         final List moods = daily[_selectedIndex]['moods'] ?? [];
         if (moods.isNotEmpty) moodKey = moods.first;
      } else if (!_isWeekly) {
         // Monthly logic - could find predominant of that week, but for now use first
         int chunkSize = (daily.length / 4).ceil();
         int start = _selectedIndex * chunkSize;
         if (start < daily.length) {
            final List moods = daily[start]['moods'] ?? [];
            if (moods.isNotEmpty) moodKey = moods.first;
         }
      }
    }
    return _moodLibrary[moodKey] ?? _moodLibrary['normal'] ?? {
      'label': 'Normal',
      'msg': 'Sigue cuidándote así de bien, preciosa.',
      'advice': 'Disfruta tu día hoy.',
      'tip': 'Bebe agua y descansa.'
    };
  }

  Widget _buildDailyAdviceCard() {
    final data = _getSelectedMoodData();
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
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data['advice'] ?? "Mímate mucho hoy.",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    final data = _getSelectedMoodData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Acerca de tus emociones",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
                style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                data['msg'] ?? "Cada emoción es un mensaje de tu corazón.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5, fontWeight: FontWeight.w500),
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
    final data = _getSelectedMoodData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tips Saludables",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
                  data['tip'] ?? "Mantén tu rutina de autocuidado.",
                  style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
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

    const double padding = 20.0;
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

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, Paint()..shader = ui.Gradient.linear(
      const Offset(0, padding), Offset(0, size.height),
      [primaryColor.withOpacity(0.3), Colors.white.withOpacity(0.0)],
    ));

    canvas.drawPath(path, Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round);

    for (int i = 0; i < points.length; i++) {
      if (selectedIndex == i) {
        canvas.drawCircle(points[i], 12, Paint()..color = primaryColor.withOpacity(0.2));
      }
      canvas.drawCircle(points[i], 6, Paint()..color = primaryColor);
      canvas.drawCircle(points[i], 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => true;
}
