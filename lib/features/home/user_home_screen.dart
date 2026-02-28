import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_service.dart';
import 'edit_period_screen.dart';
import 'add_symptoms_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/user_service.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _predictionData;
  String _userName = "...";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadData(),
      _loadUserProfile(),
    ]);
  }

  Future<void> _loadUserProfile() async {
    final result = await UserService.getUserMe();
    if (mounted && result['success']) {
      setState(() {
        final fullName = result['data']['full_name'] ?? "Usuario";
        _userName = fullName.split(' ')[0]; // Get only first name
        _email = result['data']['email'] ?? "";
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await HomeService.getPredictions();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _predictionData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        // If no data, we might need to prompt setup but here we just show empty
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9), // Very light pink
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              _buildCycleProgress(),
              const SizedBox(height: 35), // More space between circle and buttons
              _buildActionButtons(),
              const SizedBox(height: 25), // Space between buttons and cards
              _buildPredictionCards(),
              const Spacer(flex: 2), // Extra space at bottom to lift cards up
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Holiii!! Bienvenida',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => _loadAllData());
            },
          ),
        ),
      ],
    );
  }

  String _indicatorMessage = "";

  Widget _buildCycleProgress() {
    if (_isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFEBD8F5))),
      );
    }

    // --- LOGIC ---
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    // Cycle info from predictions
    int avgCycle = _predictionData?['avg_cycle_duration'] ?? 28;
    int periodDuration = _predictionData?['period_duration'] ?? 5;
    
    DateTime lastPeriodStart = today; // Default fallback
    if (_predictionData != null && _predictionData!['next_period_start'] != null) {
      DateTime nextPeriod = DateTime.parse(_predictionData!['next_period_start']);
      lastPeriodStart = nextPeriod.subtract(Duration(days: avgCycle));
    }

    // Days since last period start
    int currentCycleDay = today.difference(lastPeriodStart).inDays + 1;
    if (currentCycleDay > avgCycle) currentCycleDay = (currentCycleDay % avgCycle);
    if (currentCycleDay <= 0) currentCycleDay = 1;

    double progress = (currentCycleDay - 1) / avgCycle;

    // Stage dates
    DateTime ovulationDate = DateTime.parse(_predictionData?['ovulation_date'] ?? today.toIso8601String());
    DateTime fertileStart = DateTime.parse(_predictionData?['fertile_window']?['start'] ?? today.toIso8601String());
    
    int ovulationDay = ovulationDate.difference(lastPeriodStart).inDays + 1;
    int fertileDay = fertileStart.difference(lastPeriodStart).inDays + 1;

    // Determine current phase and next phase
    String currentPhaseText = "Fase Folicular";
    Color phaseColor = const Color(0xFFA5D6A7); // Pastel Green
    
    String nextStageTitle = "";
    int daysToNext = 0;
    Color nextStageColor = Colors.grey;

    if (currentCycleDay <= periodDuration) {
      currentPhaseText = "Menstruación";
      phaseColor = const Color(0xFFFFCDD2); // Pastel Pink
      nextStageTitle = "Ventana Fértil";
      daysToNext = fertileDay - currentCycleDay;
      nextStageColor = const Color(0xFFFFF59D); // Pastel Yellow
    } else if (currentCycleDay < fertileDay) {
      currentPhaseText = "Fase Folicular";
      phaseColor = const Color(0xFFA5D6A7); // Pastel Green
      nextStageTitle = "Ventana Fértil";
      daysToNext = fertileDay - currentCycleDay;
      nextStageColor = const Color(0xFFFFF59D); // Pastel Yellow
    } else if (currentCycleDay < ovulationDay) {
      currentPhaseText = "Ventana Fértil";
      phaseColor = const Color(0xFFFFF59D); // Pastel Yellow
      nextStageTitle = "Ovulación";
      daysToNext = ovulationDay - currentCycleDay;
      nextStageColor = const Color(0xFFFFE082); // Gold/Yellow
    } else if (currentCycleDay == ovulationDay) {
      currentPhaseText = "Ovulación";
      phaseColor = const Color(0xFFFFB74D); // Orange/Yellow
      nextStageTitle = "Próximo Periodo";
      daysToNext = avgCycle - currentCycleDay + 1;
      nextStageColor = const Color(0xFFFFCDD2); // Pastel Pink
    } else {
      currentPhaseText = "Fase Lútea";
      phaseColor = const Color(0xFFCE93D8); // Pastel Purple
      nextStageTitle = "Próximo Periodo";
      daysToNext = avgCycle - currentCycleDay + 1;
      nextStageColor = const Color(0xFFFFCDD2); // Pastel Pink
    }

    String countdownText = daysToNext == 0 ? "¡Hoy!" : "faltan $daysToNext días para $nextStageTitle";

    return Column(
      children: [
        if (_indicatorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _indicatorMessage,
              style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        GestureDetector(
          onTapDown: (details) {
            // Detect tap on indicators based on angle
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localOffset = details.localPosition;
            final Offset center = Offset(box.size.width / 2, 250 / 2 + ( _indicatorMessage.isNotEmpty ? 23 : 0)); // Approx center
            
            final double dx = localOffset.dx - center.dx;
            final double dy = localOffset.dy - center.dy;
            double angle = math.atan2(dy, dx) + math.pi / 2;
            if (angle < 0) angle += 2 * math.pi;
            
            double tapDay = (angle / (2 * math.pi)) * avgCycle;
            
            if ((tapDay - 1).abs() < 1) {
              setState(() => _indicatorMessage = "Inicio del Periodo");
            } else if ((tapDay - fertileDay).abs() < 1) {
              setState(() => _indicatorMessage = "Inicio Ventana Fértil");
            } else if ((tapDay - ovulationDay).abs() < 1) {
              setState(() => _indicatorMessage = "Día de Ovulación");
            } else {
              setState(() => _indicatorMessage = "");
            }
            
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _indicatorMessage = "");
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Shadow Circle
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: phaseColor.withAlpha(30),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Progress Ring
              SizedBox(
                width: 240,
                height: 240,
                child: CustomPaint(
                  painter: CycleProgressPainter(
                    progress: progress, 
                    color: phaseColor,
                    avgCycle: avgCycle,
                    fertileDay: fertileDay,
                    ovulationDay: ovulationDay,
                    periodDuration: periodDuration,
                  ),
                ),
              ),
              // Inner Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentPhaseText,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  Text(
                    '$currentCycleDay',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                     'día del ciclo',
                     style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: nextStageColor, width: 2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      countdownText,
                      style: TextStyle(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.edit,
          label: "Editar",
          color: const Color(0xFFEBD8F5),
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditPeriodScreen()),
            ).then((_) => _loadAllData());
          },
        ),
        _buildActionButton(
          icon: Icons.add,
          label: "Añade tus síntomas",
          color: Colors.white,
          iconColor: Colors.black,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddSymptomsScreen()),
            ).then((_) => _loadAllData());
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    Color iconColor = Colors.black54,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCards() {
    // Extraction helper
    String formatDate(String? dateStr) {
      if (dateStr == null) return "Pendiente";
      final date = DateTime.parse(dateStr);
      final months = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
      ];
      return "${date.day} de ${months[date.month - 1]}";
    }

    // Helper for relative text
    String getDaysRemaining(String? dateStr) {
       if (dateStr == null) return "Ingresa tu ciclo";
       final date = DateTime.parse(dateStr);
       final now = DateTime.now();
       final today = DateTime(now.year, now.month, now.day);
       final target = DateTime(date.year, date.month, date.day);
       
       final diff = target.difference(today).inDays;
       if (diff == 0) return "¡Hoy!";
       if (diff == 1) return "Mañana";
       if (diff < 0) return "Pasado";
       return "En $diff días aprox";
    }

    return Column(
      children: [
        _buildCard(
          title: "Predicción Ovulación",
          date: formatDate(_predictionData?['ovulation_date']),
          subtitle: getDaysRemaining(_predictionData?['ovulation_date']),
          color: const Color(0xFFD4E2FF),
          bubbleOnLeft: true,
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: "Ventana Fértil",
          date: formatDate(_predictionData?['fertile_window']?['start']),
          subtitle: getDaysRemaining(_predictionData?['fertile_window']?['start']),
          color: const Color(0xFFFFE5E9),
          bubbleOnLeft: true,
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: "Próxima Menstruación",
          date: formatDate(_predictionData?['next_period_start']),
          subtitle: getDaysRemaining(_predictionData?['next_period_start']),
          color: const Color(0xFFEBD8F5),
          bubbleOnLeft: true,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String date,
    required String subtitle,
    required Color color,
    required bool bubbleOnLeft,
  }) {
    return Container(
      width: double.infinity,
      height: 85, // Increased height for larger cards
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(8), // Consistent inner padding
      child: Row(
        children: [
          if (bubbleOnLeft) ...[
            _buildBubble(title),
            Expanded(child: _buildCardDateInfo(date, subtitle, false)),
          ] else ...[
            Expanded(child: _buildCardDateInfo(date, subtitle, true)),
            _buildBubble(title),
          ]
        ],
      ),
    );
  }

  Widget _buildBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(minWidth: 130, maxWidth: 160),
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(160),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withAlpha(180), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 12,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCardDateInfo(String top, String bottom, bool alignLeft) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            top,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
          ),
          Text(
            bottom,
            style: TextStyle(color: Colors.black.withAlpha(120), fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class CycleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int avgCycle;
  final int fertileDay;
  final int ovulationDay;
  final int periodDuration;

  CycleProgressPainter({
    required this.progress, 
    required this.color,
    required this.avgCycle,
    required this.fertileDay,
    required this.ovulationDay,
    required this.periodDuration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = Colors.grey.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      paint,
    );

    // Progress track with Gradient feel
    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    // STATIC INDICATORS
    void drawIndicator(int day, Color indicatorColor) {
      final angle = -math.pi / 2 + (2 * math.pi * ((day - 1) / avgCycle));
      final offset = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(offset, 10, dotPaint);
      
      final borderPaint = Paint()..color = indicatorColor..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawCircle(offset, 10, borderPaint);
    }

    drawIndicator(1, const Color(0xFFFFCDD2)); // Period Start (Pink)
    drawIndicator(fertileDay, const Color(0xFFFFF59D)); // Fertile Start (Yellow)
    drawIndicator(ovulationDay, const Color(0xFFFFB74D)); // Ovulation (Orange)

    // Handle (Current Progress Dot)
    final angle = -math.pi / 2 + (2 * math.pi * progress);
    final handleOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(handleOffset, 16, dotPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(handleOffset, 16, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

