import 'package:flutter/material.dart';

class PredictionCard extends StatelessWidget {
  final Map<String, dynamic>? predictionData;
  final void Function(String type)? onTap;

  const PredictionCard({super.key, required this.predictionData, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Extraction helper
    String formatDate(String? dateStr) {
      if (dateStr == null) return "Pendiente";
      try {
        final date = DateTime.parse(dateStr);
        final months = [
          "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
          "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
        ];
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
          date: formatDate(predictionData?['fertile_window']?['start']),
          subtitle: getDaysRemaining(predictionData?['fertile_window']?['start']),
          color: const Color(0xFFD4E2FF),
          bubbleOnLeft: true,
          onTap: () => onTap?.call("fertile"),
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: "Predicción Ovulación",
          date: formatDate(predictionData?['ovulation_date']),
          subtitle: getDaysRemaining(predictionData?['ovulation_date']),
          color: const Color(0xFFFFE5E9),
          bubbleOnLeft: true,
          onTap: () => onTap?.call("ovulation"),
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: "Próxima Menstruación",
          date: formatDate(predictionData?['next_period_start']),
          subtitle: getDaysRemaining(predictionData?['next_period_start']),
          color: const Color(0xFFEBD8F5),
          bubbleOnLeft: true,
          onTap: () => onTap?.call("period"),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              _buildBubble(title),
              Expanded(child: _buildCardDateInfo(date, subtitle, false)),
            ] else ...[
              Expanded(child: _buildCardDateInfo(date, subtitle, true)),
              _buildBubble(title),
            ]
          ],
        ),
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
