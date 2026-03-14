import 'package:flutter/material.dart';

class AdvancedStatsCard extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const AdvancedStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen del Sistema',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildStatRow(
              Icons.people_outline, 'Total Usuarias', '${stats?['total_users'] ?? 0}', Colors.blue),
          const SizedBox(height: 16),
          _buildStatRow(
              Icons.calendar_today_outlined, 'Ciclos Registrados', '${stats?['total_cycles'] ?? 0}', Colors.pink[300]!),
          const SizedBox(height: 16),
          _buildStatRow(
              Icons.timer_outlined, 'Promedio de Ciclo', '${stats?['avg_cycle_duration'] ?? 28} días', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).toInt()), shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
