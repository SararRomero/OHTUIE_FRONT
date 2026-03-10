import 'package:flutter/material.dart';

class LastPeriodPage extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const LastPeriodPage({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '¿Cuándo fue tu último periodo?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              'lib/assets/image/toalla.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.sanitizer, size: 100, color: Colors.pink),
            ),
          ),
        ),
        const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(primary: Color(0xFFFF4081)),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).toInt()),
                    blurRadius: 10,
                  )
                ]
              ),
              child: Text(
                "${selectedDate.day} / ${selectedDate.month} / ${selectedDate.year}",
                style: const TextStyle(fontSize: 24, color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Ingresa el primer día de tu última menstruación",
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text("Toca para cambiar", style: TextStyle(color: Colors.grey)),
          const Spacer(flex: 1),
      ],
    );
  }
}
