import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../home/user_home_screen.dart';
import 'widgets/birthday_page.dart';
import 'widgets/cycle_duration_page.dart';
import 'widgets/last_period_page.dart';
import 'widgets/period_duration_page.dart';
import '../../core/widgets/cycle_loading_button.dart';

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
  
  // State variables for the inputs
  int _cycleDuration = 28;
  int _periodDuration = 5;
  DateTime _lastPeriodDate = DateTime.now();
  DateTime _birthday = DateTime.now();
  bool _isLoading = false;

  // Colors for the button for each step
  final List<Color> _buttonColors = [
    const Color(0xFFE91E63), // Step 1 (Strong Pink)
    const Color(0xFFE91E63), // Step 2 (Strong Pink)
    const Color(0xFFE91E63), // Step 3 (Strong Pink)
    const Color(0xFFFFE4EF), // Step 4 (Light Pink for Birthday)
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextTap() async {
    if (_isLoading) return;
    
    // Only show artificial delay for intermediate step transitions
    if (_currentPage < 3) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _isLoading = false);
    }

    _nextPage();
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
      if (result['success']) {
        final loginResult = await AuthService.login(widget.email, widget.password);
        if (mounted) {
          setState(() => _isLoading = false);
          if (loginResult['success']) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const UserHomeScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      } else {
        setState(() => _isLoading = false);
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
    // If it's the last page and loading, show blue color
    if (_currentPage == 3 && _isLoading) {
      return AppColors.accent;
    }
    
    if (_currentPage < _buttonColors.length) {
      return _buttonColors[_currentPage];
    }
    return _buttonColors.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async => !_isLoading,
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
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CycleDurationPage(
                        initialValue: _cycleDuration,
                        onChanged: (val) => setState(() => _cycleDuration = val),
                      ),
                      PeriodDurationPage(
                        initialValue: _periodDuration,
                        onChanged: (val) => setState(() => _periodDuration = val),
                      ),
                      LastPeriodPage(
                        selectedDate: _lastPeriodDate,
                        onDateSelected: (date) => setState(() => _lastPeriodDate = date),
                      ),
                      BirthdayPage(
                        birthday: _birthday,
                        onBirthdayChanged: (date) => setState(() => _birthday = date),
                      ),
                    ],
                  ),
                ),
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
                      CycleLoadingButton(
                        text: "", // No text for this icon button
                        icon: Icons.arrow_forward,
                        isLoading: _isLoading,
                        onPressed: _onNextTap,
                        backgroundColor: _getCurrentButtonColor(),
                        borderRadius: 35,
                        width: 70,
                        height: 70,
                        loadingColor: Colors.white,
                        showBorderAnimation: false,
                        useBorealisAnimation: true,
                      ),
                const SizedBox(height: 40),
              ],
            ),
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
                  onPressed: _isLoading ? null : () {
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
      ),
    );
  }
}
