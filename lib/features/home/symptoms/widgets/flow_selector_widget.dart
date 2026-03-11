import 'package:flutter/material.dart';

class FlowSelectorWidget extends StatelessWidget {
  final String? selectedFlow;
  final ValueChanged<String> onChanged;

  const FlowSelectorWidget({
    super.key,
    required this.selectedFlow,
    required this.onChanged,
  });

  static const Map<String, String> _flowOptions = {
    'none': 'Ninguno',
    'light': 'Bajo',
    'medium': 'Normal',
    'heavy': 'Alto',
  };

  static const Map<String, String> _flowImages = {
    'none': 'lib/assets/image/flujo_ninguno.png',
    'light': 'lib/assets/image/flujo_bajo.png',
    'medium': 'lib/assets/image/flujo_normal.png',
    'heavy': 'lib/assets/image/flujo_alto.png',
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2; // 2 items per row, 12 spacing
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _flowOptions.entries.map((entry) {
            final isSelected = selectedFlow == entry.key;
            final imagePath = _flowImages[entry.key]!;

            return GestureDetector(
              onTap: () => onChanged(entry.key),
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
                      imagePath,
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black87,
                        ),
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
