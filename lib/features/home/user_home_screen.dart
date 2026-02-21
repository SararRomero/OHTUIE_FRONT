import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_service.dart';
import 'edit_period_screen.dart';
import 'add_symptoms_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _predictionData;
  final String _userName = "Luisa"; // Default, should fetch from current user

  @override
  void initState() {
    super.initState();
    _loadData();
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
              // Menu action
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCycleProgress() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFEBD8F5))),
      );
    }

    // Logic for days until ovulation
    int daysUntilOvulation = 0;
    int daysLeft = 0;
    
    if (_predictionData != null && _predictionData!['ovulation_date'] != null) {
      final ovulationDate = DateTime.parse(_predictionData!['ovulation_date']);
      daysUntilOvulation = ovulationDate.difference(DateTime.now()).inDays;
      if (daysUntilOvulation < 0) daysUntilOvulation = 0;
      
      if (_predictionData!['next_period_start'] != null) {
        final nextPeriod = DateTime.parse(_predictionData!['next_period_start']);
        daysLeft = nextPeriod.difference(DateTime.now()).inDays;
        if (daysLeft < 0) daysLeft = 0;
      }
    }

    return Stack(
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
                color: Colors.pink.withAlpha(15),
                blurRadius: 30,
                spreadRadius: 8,
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
              progress: 0.7, 
              color: const Color(0xFFEBD8F5),
            ),
          ),
        ),
        // Inner Content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ovulación en',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            Text(
              '$daysUntilOvulation días',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'faltan $daysLeft días',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.water_drop_outlined,
          label: "Editar",
          color: const Color(0xFFEBD8F5),
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditPeriodScreen()),
            ).then((_) => _loadData());
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
            ).then((_) => _loadData());
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
      if (dateStr == null) return "TBD";
      final date = DateTime.parse(dateStr);
      final months = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
      ];
      return "${months[date.month - 1]} ${date.day}";
    }

    // Helper for relative text
    String getDaysRemaining(String? dateStr) {
       if (dateStr == null) return "Proximamente";
       final date = DateTime.parse(dateStr);
       final diff = date.difference(DateTime.now()).inDays;
       if (diff <= 0) return "Muy pronto";
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
          bubbleOnLeft: false,
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

  CycleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = color.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      paint,
    );

    // Progress track
    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    // Handle (Dot)
    final angle = -math.pi / 2 + (2 * math.pi * progress);
    final handleOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(handleOffset, 16, dotPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFB39DDB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(handleOffset, 16, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

