import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/sign_up_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Container(
              color: AppColors.primaryLight,
              child: CustomPaint(
                painter: BackgroundPainter(),
              ),
            ),
          ),
          // Animated Logo Center
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Using the asset image as requested
                    Image.asset(
                      'lib/assets/image/logo.png',
                      width: 250, // Increased size since it's now alone
                      height: 250,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.spa, size: 100, color: Color(0xFFFF4081));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    // ... (Painting code same as before)
    // Top Left - Light Blue
    paint.color = const Color(0xFFCCDDFF).withOpacity(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-20, -20, size.width * 0.4, size.height * 0.25),
        const Radius.circular(20),
      ),
      paint,
    );
    // ... rest of the painting
     // Top Right - Top
    paint.color = const Color(0xFFFFE4EF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.5, -50, size.width * 0.6, size.height * 0.3),
        const Radius.circular(20),
      ),
      paint,
    );
    // Middle Blue
    paint.color = const Color(0xFFCCDDFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.15, size.width * 0.5, size.height * 0.20),
        const Radius.circular(20),
      ),
      paint,
    );
    // Bottom Right Blue
    paint.color = const Color(0xFFCCDDFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.6, size.height * 0.45, size.width * 0.5, size.height * 0.35),
        const Radius.circular(20),
      ),
      paint,
    );
     // Bottom Left Pink
    paint.color = const Color(0xFFFFE4EF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-40, size.height * 0.6, size.width * 0.4, size.height * 0.3),
        const Radius.circular(20),
      ),
      paint,
    );
     // Bottom Center Blue
    paint.color = const Color(0xFFCCDDFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, size.height * 0.85, size.width * 0.5, size.height * 0.2),
        const Radius.circular(20),
      ),
      paint,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
