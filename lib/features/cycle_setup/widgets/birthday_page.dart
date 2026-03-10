import 'package:flutter/material.dart';

class BirthdayPage extends StatefulWidget {
  final DateTime birthday;
  final ValueChanged<DateTime> onBirthdayChanged;

  const BirthdayPage({
    super.key,
    required this.birthday,
    required this.onBirthdayChanged,
  });

  @override
  State<BirthdayPage> createState() => _BirthdayPageState();
}

class _BirthdayPageState extends State<BirthdayPage> {
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  final List<String> _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  final List<int> _years = List.generate(
    DateTime.now().year - 1899,
    (index) => 1900 + index,
  );

  @override
  void initState() {
    super.initState();
    _dayController = FixedExtentScrollController(initialItem: widget.birthday.day - 1);
    _monthController = FixedExtentScrollController(initialItem: widget.birthday.month - 1);
    _yearController = FixedExtentScrollController(initialItem: _years.indexOf(widget.birthday.year));
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _updateDate() {
    int day = _dayController.selectedItem + 1;
    int month = _monthController.selectedItem + 1;
    int year = _years[_yearController.selectedItem];

    // Basic date validation for leap years and short months
    int maxDays = DateTime(year, month + 1, 0).day;
    if (day > maxDays) day = maxDays;

    widget.onBirthdayChanged(DateTime(year, month, day));
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
            '¿Cuándo es tu cumpleaños?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          flex: 8,
          child: Center(
            child: SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Indicator Lines
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: const Color(0xFFFF4081).withAlpha((0.3 * 255).toInt()), width: 1.5),
                        bottom: BorderSide(color: const Color(0xFFFF4081).withAlpha((0.3 * 255).toInt()), width: 1.5),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day Wheel
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _dayController,
                          itemExtent: 50,
                          perspective: 0.005,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (_) => _updateDate(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= 31) return null;
                              final val = index + 1;
                              final isSelected = val == widget.birthday.day;
                              return Center(
                                child: Text(
                                  '$val',
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? const Color(0xFFFF4081) : Colors.grey.withAlpha((0.6 * 255).toInt()),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Month Wheel
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _monthController,
                          itemExtent: 50,
                          perspective: 0.005,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (_) => _updateDate(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= 12) return null;
                              final month = _months[index];
                              final isSelected = (index + 1) == widget.birthday.month;
                              return Center(
                                child: Text(
                                  month,
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? const Color(0xFFFF4081) : Colors.grey.withAlpha((0.6 * 255).toInt()),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Year Wheel
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _yearController,
                          itemExtent: 50,
                          perspective: 0.005,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (_) => _updateDate(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= _years.length) return null;
                              final year = _years[index];
                              final isSelected = year == widget.birthday.year;
                              return Center(
                                child: Text(
                                  '$year',
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? const Color(0xFFFF4081) : Colors.grey.withAlpha((0.6 * 255).toInt()),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }
}
