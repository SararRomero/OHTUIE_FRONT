import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'package:ohtuie_app2/features/cycles_history/cycles_history_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ohtuie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CyclesHistoryScreen(),
    );
  }
}
