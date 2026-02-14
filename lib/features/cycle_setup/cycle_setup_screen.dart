import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CycleSetupScreen extends StatefulWidget {
  const CycleSetupScreen({super.key});

  @override
  State<CycleSetupScreen> createState() => _CycleSetupScreenState();
}

class _CycleSetupScreenState extends State<CycleSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State variables for the inputs
  int _cycleDuration = 28;
  int _periodDuration = 5;
  DateTime _lastPeriodDate = DateTime.now();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Finish setup, navigate to Home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setup Completed! Navigating to Home...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5), // Light Pink Background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildCycleDurationPage(),
                  _buildPeriodDurationPage(),
                  _buildLastPeriodPage(),
                ],
              ),
            ),
            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? const Color(0xFFFF4081)
                              : const Color(0xFFFFC1E3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Next Button
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB7C5), // Soft Pink Button
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleDurationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Ingrese la duración de su ciclo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        const SizedBox(height: 40),
        // Image Placeholder - Uterus
        SizedBox(
          height: 200,
          child: Image.asset(
            'assets/images/uterus.png',
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.favorite, size: 100, color: Color(0xFFFF80AB)),
          ),
        ),
        const SizedBox(height: 40),
        // Number Picker Simulation (Simple ListWheelScrollView)
        SizedBox(
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
               Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.pink.withValues(alpha: 0.2)),
                    bottom: BorderSide(color: Colors.pink.withValues(alpha: 0.2)),
                  )
                ),
               ),
              ListWheelScrollView.useDelegate(
                itemExtent: 50,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() => _cycleDuration = index + 20); // Starting from 20 for example
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final value = index + 20;
                    final isSelected = value == _cycleDuration;
                    return Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 20,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFFFF4081) : Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodDurationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Duración de su período',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        const SizedBox(height: 40),
        // Image Placeholder - Drop
        SizedBox(
          height: 200,
          child: Image.asset(
            'assets/images/drop.png',
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.water_drop, size: 100, color: Colors.redAccent),
          ),
        ),
        const SizedBox(height: 40),
        // Number Picker
         SizedBox(
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
               Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.pink.withValues(alpha: 0.2)),
                    bottom: BorderSide(color: Colors.pink.withValues(alpha: 0.2)),
                  )
                ),
               ),
              ListWheelScrollView.useDelegate(
                itemExtent: 50,
                perspective: 0.005,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() => _periodDuration = index + 1);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final value = index + 1;
                    final isSelected = value == _periodDuration;
                    return Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 20,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFFFF4081) : Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLastPeriodPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Cuando fue su ultimo periodo?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        const SizedBox(height: 40),
        // Image Placeholder - Pad
        SizedBox(
          height: 200,
          child: Image.asset(
            'assets/images/pad.png',
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.sanitizer, size: 100, color: Colors.pink),
          ),
        ),
        const SizedBox(height: 40),
        // Simple Date Picker Display (Interactive)
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _lastPeriodDate,
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
            if (picked != null && picked != _lastPeriodDate) {
              setState(() {
                _lastPeriodDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                )
              ]
            ),
            child: Text(
              "${_lastPeriodDate.day} / ${_lastPeriodDate.month} / ${_lastPeriodDate.year}",
              style: const TextStyle(fontSize: 24, color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Tap to change", style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
