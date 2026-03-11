import 'package:flutter/material.dart';

class SymptomSelectorWidget extends StatelessWidget {
  final List<String> selectedSymptoms;
  final Function(String, bool) onToggle;

  const SymptomSelectorWidget({
    super.key,
    required this.selectedSymptoms,
    required this.onToggle,
  });

  static const List<Map<String, String>> _symptomOptions = [
    {'id': 'aching_head', 'label': 'Dolor de cabeza', 'imagePath': 'lib/assets/image/dolor_de_cabeza.png'},
    {'id': 'add_weight', 'label': 'Aumento de peso', 'imagePath': 'lib/assets/image/peso.png'},
    {'id': 'cramps', 'label': 'Cólicos', 'imagePath': 'lib/assets/image/colicos.png'},
    {'id': 'bloating', 'label': 'Hinchazón', 'imagePath': 'lib/assets/image/hinchazon.png'},
    {'id': 'fatigue', 'label': 'Fatiga', 'imagePath': 'lib/assets/image/fatiga.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _symptomOptions.map((s) {
            final isSelected = selectedSymptoms.contains(s['id']);
            return GestureDetector(
              onTap: () => onToggle(s['id']!, !isSelected),
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
                      s['imagePath']!,
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s['label']!,
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
