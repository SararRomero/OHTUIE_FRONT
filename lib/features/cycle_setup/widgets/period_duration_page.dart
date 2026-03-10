import 'package:flutter/material.dart';

class PeriodDurationPage extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const PeriodDurationPage({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<PeriodDurationPage> createState() => _PeriodDurationPageState();
}

class _PeriodDurationPageState extends State<PeriodDurationPage> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: widget.initialValue - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Duración de tu periodo',
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
              'lib/assets/image/gota.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.water_drop, size: 100, color: Colors.redAccent),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
               Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.pink.withAlpha((0.2 * 255).toInt())),
                    bottom: BorderSide(color: Colors.pink.withAlpha((0.2 * 255).toInt())),
                  )
                ),
               ),
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: 50,
                perspective: 0.005,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  widget.onChanged(index + 1);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final value = index + 1;
                    final isSelected = value == widget.initialValue;
                    return Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 20,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFFFF4081) : Colors.grey.withAlpha((0.5 * 255).toInt()),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }
}
