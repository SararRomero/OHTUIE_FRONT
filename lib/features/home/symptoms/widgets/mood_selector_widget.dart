import 'package:flutter/material.dart';

class MoodSelectorWidget extends StatelessWidget {
  final List<String> selectedMoods;
  final Function(String, bool) onToggle;

  const MoodSelectorWidget({
    super.key,
    required this.selectedMoods,
    required this.onToggle,
  });

  static const List<Map<String, String>> _moodOptions = [
    {'id': 'normal', 'label': 'Normal', 'imagePath': 'lib/assets/image/animo_normal.png'},
    {'id': 'angry', 'label': 'Enojada', 'imagePath': 'lib/assets/image/enojada.png'},
    {'id': 'happy', 'label': 'Feliz', 'imagePath': 'lib/assets/image/feliz.png'},
    {'id': 'sad', 'label': 'Triste', 'imagePath': 'lib/assets/image/triste.png'},
    {'id': 'calm', 'label': 'Tranquila', 'imagePath': 'lib/assets/image/tranquila.png'},
    {'id': 'tired', 'label': 'Cansada', 'imagePath': 'lib/assets/image/cansada.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _moodOptions.map((m) {
            final isSelected = selectedMoods.contains(m['id']);
            return GestureDetector(
              onTap: () => onToggle(m['id']!, !isSelected),
              child: Container(
                width: itemWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected 
                      ? Border.all(color: const Color(0xFFFF4081), width: 1.5) 
                      : Border.all(color: Colors.transparent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      m['imagePath']!,
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
