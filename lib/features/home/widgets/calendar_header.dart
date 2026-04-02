import 'package:flutter/material.dart';

class CalendarHeader extends StatelessWidget {
  final dynamic popResult;
  const CalendarHeader({super.key, this.popResult});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context, popResult),
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFF5F5F5)),
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              "Calendario",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}
