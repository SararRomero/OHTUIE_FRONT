import 'package:flutter/material.dart';
import '../calendar_screen.dart'; // To access the painter if needed or I can move it here

class CalendarDayItem extends StatelessWidget {
  final int day;
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final Color dayColor;
  final bool isOvulation;
  final VoidCallback onTap;

  const CalendarDayItem({
    super.key,
    required this.day,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.dayColor,
    required this.isOvulation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dayColor,
          shape: BoxShape.circle,
          border: isSelected 
              ? Border.all(color: Colors.black26, width: 2) 
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isOvulation)
              SizedBox(
                width: 32,
                height: 32,
                child: CustomPaint(
                  painter: OvulationFlowerPainter(color: const Color(0xFFFFB2C1).withOpacity(0.9)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                "$day",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? const Color(0xFFFF4081) : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
