import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';

class CycleSetupScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const CycleSetupScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<CycleSetupScreen> createState() => _CycleSetupScreenState();
}

class _CycleSetupScreenState extends State<CycleSetupScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Animation Controller for Ripple Effect
  late AnimationController _rippleController;

  // State variables for the inputs
  int _cycleDuration = 28;
  int _periodDuration = 5;
  DateTime _lastPeriodDate = DateTime.now();
  DateTime _birthday = DateTime(2000, 1, 1);
  bool _isLoading = false;

  // Colors for the button for each step
  final List<Color> _buttonColors = [
    const Color(0xFFBFD4FF), // Step 1
    const Color(0xFFFFDCE0), // Step 2
    const Color(0xFFEBD8F5), // Step 3
    const Color(0xFFFFE4EF), // Step 4
  ];
  

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Slower animation for broader ripples
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onNextTap() {
    if (_isLoading) return;
    
    // Start animation
    _rippleController.forward(from: 0.0).then((_) {
      // After animation completes (or partly during), proceed to next page
      _nextPage();
    });
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleFinalRegistration();
    }
  }

  void _handleFinalRegistration() async {
    setState(() => _isLoading = true);

    final result = await AuthService.signUp(
      email: widget.email,
      password: widget.password,
      fullName: widget.name,
      birthday: _birthday,
      cycleStartDate: _lastPeriodDate,
      cycleDuration: _cycleDuration,
      periodDuration: _periodDuration,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Por favor, inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getCurrentButtonColor() {
    if (_currentPage < _buttonColors.length) {
      return _buttonColors[_currentPage];
    }
    return _buttonColors.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5), // Light Pink Background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe
                    children: [
                      _buildCycleDurationPage(),
                      _buildPeriodDurationPage(),
                      _buildLastPeriodPage(),
                      _buildBirthdayPage(),
                    ],
                  ),
                ),
                // Page Indicator moved up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? _getCurrentButtonColor()
                            : Colors.grey.withAlpha((0.3 * 255).toInt()),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                // Next Button with Animation
                GestureDetector(
                  onTap: _onNextTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple Animation Layer
                       AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(120, 120), // Reduced from 200 for smaller ripples
                            painter: _RipplePainter(
                              animation: _rippleController,
                              colors: _getRippleColors(),
                            ),
                          );
                        },
                      ),
                      // The Button Itself
                      Container(
                        width: 70, 
                        height: 70,
                        decoration: BoxDecoration(
                          color: _getCurrentButtonColor(),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getCurrentButtonColor().withAlpha((0.4 * 255).toInt()),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _isLoading 
                          ? const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
             // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.05 * 255).toInt()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                  onPressed: () {
                    if (_currentPage > 0) {
                       _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getRippleColors() {
    List<Color> availableColors = List.from(_buttonColors);
    availableColors.removeAt(_currentPage);
    // Return the first two available colors that aren't the button's color.
    return [availableColors[0], availableColors[1]];
  }

  Widget _buildCycleDurationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Ingresa la duración de tu ciclo',
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
              'lib/assets/image/utero.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.favorite, size: 100, color: Color(0xFFFF80AB)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120, // slightly reduced to ensure it fits mobile screens perfectly
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
                itemExtent: 50,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() => _cycleDuration = index + 20);
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

  Widget _buildPeriodDurationPage() {
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
          height: 120, // reduced to perfectly fit selectors above page indicators
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

  Widget _buildLastPeriodPage() {
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
                    color: Colors.black.withAlpha((0.05 * 255).toInt()),
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
          const Text("Toca para cambiar", style: TextStyle(color: Colors.grey)),
          const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildBirthdayPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '¿Cuándo es tu cumpleaños?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        const SizedBox(height: 20),
        const Expanded(
            flex: 6,
            child: Center(
              child: Icon(Icons.cake_outlined, size: 150, color: Color(0xFFFF80AB)),
            ),
        ),
        const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _birthday,
                firstDate: DateTime(1900),
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
              if (picked != null && picked != _birthday) {
                setState(() {
                  _birthday = picked;
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
                    color: Colors.black.withAlpha((0.05 * 255).toInt()),
                    blurRadius: 10,
                  )
                ]
              ),
              child: Text(
                "${_birthday.day} / ${_birthday.month} / ${_birthday.year}",
                style: const TextStyle(fontSize: 24, color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Toca para cambiar", style: TextStyle(color: Colors.grey)),
          const Spacer(flex: 1),
      ],
    );
  }
}

// Custom Painter for Ripple Effect
class _RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  _RipplePainter({required this.animation, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    // We want exactly 2 circles
    final int rippleCount = 2;
    
    for (int i = 0; i < rippleCount; i++) {
        // Stagger the ripples
        // We want them to appear sequentially but overlap significantly
        
        double stagger = 0.35; 
        double start = i * stagger;
        
        // Calculate t for this specific ripple
        double t = (animation.value - start) / 0.65;
        
        if (t >= 0.0 && t <= 1.0) {
             final double radius = 35 + (maxRadius - 35) * t;
             final double opacity = (1.0 - t).clamp(0.0, 1.0);
             
             final Color color = colors[i % colors.length];

             final paint = Paint()
              ..color = color.withAlpha((opacity * 0.6 * 255).toInt()) // Reduced base opacity
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4 + (4 * (1.0 - t)); 

            canvas.drawCircle(center, radius, paint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return true; 
  }
}
