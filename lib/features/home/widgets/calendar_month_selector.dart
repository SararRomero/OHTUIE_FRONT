import 'package:flutter/material.dart';

class CalendarMonthSelector extends StatelessWidget {
  final DateTime focusedDay;
  final String monthName;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const CalendarMonthSelector({
    super.key,
    required this.focusedDay,
    required this.monthName,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: canGoBack ? onPrevious : null,
          icon: Icon(Icons.chevron_left, color: canGoBack ? Colors.black54 : Colors.black12),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFF5F5F5)),
            ),
          ),
        ),
        Text(
          "$monthName ${focusedDay.year}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: canGoForward ? onNext : null,
          icon: Icon(Icons.chevron_right, color: canGoForward ? Colors.black54 : Colors.black12),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFF5F5F5)),
            ),
          ),
        ),
      ],
    );
  }
}
