import 'package:flutter/material.dart';

class PredictionCard extends StatefulWidget {
  final Map<String, dynamic>? predictionData;
  final void Function(String type)? onTap;
  final void Function(String type)? onCardTap;

  const PredictionCard({super.key, required this.predictionData, this.onTap, this.onCardTap});

  @override
  State<PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<PredictionCard> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // Extraction helper
    String formatDate(String? dateStr, {String? endDateStr}) {
      if (dateStr == null) return "Pendiente";
      try {
        final date = DateTime.parse(dateStr);
        final months = [
          "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
          "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
        ];

        if (endDateStr != null) {
          final endDate = DateTime.parse(endDateStr);
          if (date.month == endDate.month) {
            return "${date.day} - ${endDate.day} de ${months[date.month - 1]}";
          } else {
             final shortMonths = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
             return "${date.day} ${shortMonths[date.month - 1]} - ${endDate.day} ${shortMonths[endDate.month - 1]}";
          }
        }

        return "${date.day} de ${months[date.month - 1]}";
      } catch (e) {
        return "Fecha inválida";
      }
    }

    // Helper for relative text
    String getDaysRemaining(String? dateStr) {
       if (dateStr == null) return "Ingresa tu ciclo";
       try {
         final date = DateTime.parse(dateStr);
         final now = DateTime.now();
         final today = DateTime(now.year, now.month, now.day);
         final target = DateTime(date.year, date.month, date.day);
         
         final diff = target.difference(today).inDays;
         if (diff == 0) return "¡Hoy!";
         if (diff == 1) return "Mañana";
         if (diff < 0) return "Pasado";
         return "En $diff días aprox";
       } catch (e) {
         return "";
       }
    }

    return Column(
      children: [
        _buildCard(
          title: "Ventana Fértil",
          date: formatDate(
            widget.predictionData?['fertile_window']?['start'],
            endDateStr: widget.predictionData?['fertile_window']?['end'],
          ),
          subtitle: getDaysRemaining(widget.predictionData?['fertile_window']?['start']),
          color: const Color(0xFFD4E2FF),
          bubbleOnLeft: true,
          type: "fertile",
          index: 0,
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: "Predicción Ovulación",
          date: formatDate(widget.predictionData?['ovulation_date']),
          subtitle: getDaysRemaining(widget.predictionData?['ovulation_date']),
          color: const Color(0xFFFFE5E9),
          bubbleOnLeft: true,
          type: "ovulation",
          index: 1,
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: "Próxima Menstruación",
          date: formatDate(widget.predictionData?['next_period_start']),
          subtitle: getDaysRemaining(widget.predictionData?['next_period_start']),
          color: const Color(0xFFEBD8F5),
          bubbleOnLeft: true,
          type: "period",
          index: 2,
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
    required String type,
    required int index,
  }) {
    return Container(
      width: double.infinity,
      height: 85,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (bubbleOnLeft) ...[
            _PredictionBubble(
              text: title, 
              index: index, 
              onTap: () => widget.onTap?.call(type),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => widget.onCardTap?.call(type),
                behavior: HitTestBehavior.opaque,
                child: _buildCardDateInfo(date, subtitle, false),
              ),
            ),
          ] else ...[
            Expanded(
              child: GestureDetector(
                onTap: () => widget.onCardTap?.call(type),
                behavior: HitTestBehavior.opaque,
                child: _buildCardDateInfo(date, subtitle, true),
              ),
            ),
            _PredictionBubble(
              text: title, 
              index: index, 
              onTap: () => widget.onTap?.call(type),
            ),
          ]
        ],
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

class _PredictionBubble extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final int index;

  const _PredictionBubble({required this.text, this.onTap, required this.index});

  @override
  State<_PredictionBubble> createState() => _PredictionBubbleState();
}

class _PredictionBubbleState extends State<_PredictionBubble> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. Entrance "Pop up" Animation
    _entranceController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 700),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController, 
      curve: Curves.elasticOut,
    );
    
    // Delayed start based on index
    Future.delayed(Duration(milliseconds: 300 + (widget.index * 150)), () {
      if (mounted) _entranceController.forward();
    });

    // 2. Press "Bounce and Enlarge" Animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Reverse logic for bounce
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _entranceAnimation,
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
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
              widget.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
