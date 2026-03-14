import 'package:flutter/material.dart';

class SecurityStatsSection extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const SecurityStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de Seguridad',
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
                        color: Colors.green.withAlpha((0.1 * 255).toInt()),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.shield_outlined,
                        size: 16, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  const Text('Intentos fallidos hoy',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              Text('${stats?['failed_logins_today'] ?? 0}',
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
                        color: Colors.orange.withAlpha((0.1 * 255).toInt()),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.lock_outline,
                        size: 16, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  const Text('Usuarios bloqueados',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              const Text('0',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
