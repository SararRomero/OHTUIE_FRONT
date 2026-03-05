import 'package:flutter/material.dart';
import '../edit_period_screen.dart';
import '../add_symptoms_screen.dart';

class HomeActionButtons extends StatelessWidget {
  final VoidCallback onRefresh;

  const HomeActionButtons({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.water_drop_outlined,
          label: "Editar",
          color: const Color(0xFFC5B4E3), // Shaded purple like in user screenshot
          iconColor: Colors.black87,
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditPeriodScreen()),
            ).then((_) => onRefresh());
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.add,
          label: "Añade tus síntomas",
          color: Colors.white,
          iconColor: Colors.black,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddSymptomsScreen()),
            ).then((_) => onRefresh());
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
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
}
