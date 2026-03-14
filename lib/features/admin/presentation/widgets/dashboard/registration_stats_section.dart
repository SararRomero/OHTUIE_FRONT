import 'package:flutter/material.dart';

class RegistrationStatsSection extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const RegistrationStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de Registros',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.blue.withAlpha((0.1 * 255).toInt()),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline,
                        size: 16, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Text('Usuarias registradas hoy',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              Text('${stats?['registrations_today'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.1 * 255).toInt()),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.report_problem_outlined,
                        size: 16, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  const Text('Registros sospechosos',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              Text('${stats?['suspicious_registrations_count'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
