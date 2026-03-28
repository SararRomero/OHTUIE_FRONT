import 'package:flutter/material.dart';
import 'home_service.dart';
import 'calendar_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/user_service.dart';
import 'widgets/cycle_progress_indicator.dart';
import 'widgets/home_action_buttons.dart';
import 'widgets/prediction_card.dart';
import '../../core/widgets/session_expired_modal.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _predictionData;
  Map<String, dynamic>? _userProfileData;
  String _userName = "...";
  final GlobalKey<CycleProgressIndicatorState> _indicatorKey = GlobalKey<CycleProgressIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // If we have data already, we might not want to show the full loading spinner
    // but rather just refresh in the background or show a subtle progress bar.
    // For now, let's just make the requests concurrent for speed.
    await Future.wait([
      _loadData(),
      _loadUserProfile(),
    ]);
  }

  Future<void> _loadUserProfile() async {
    final result = await UserService.getUserMe();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _userProfileData = result['data'];
          final fullName = _userProfileData!['full_name'] ?? "Usuario";
          _userName = fullName.split(' ')[0]; // Get only first name
        });
      } else {
        final message = result['message'].toString().toLowerCase();
        if (message.contains("credentials") || message.contains("unauthorized") || message.contains("401")) {
          _showSessionExpired();
        }
      }
    }
  }

  void _showSessionExpired() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => const SessionExpiredModal(),
      );
    }
  }

  Future<void> _loadData() async {
    // Don't set _isLoading to true if we already have data (refreshing)
    if (_predictionData == null) {
      setState(() => _isLoading = true);
    }
    
    final result = await HomeService.getPredictions();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _predictionData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        final message = result['message'].toString().toLowerCase();
        if (message.contains("credentials") || message.contains("unauthorized") || message.contains("401")) {
          _showSessionExpired();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFF0F2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFEBD8F5))),
                  )
                else if (_predictionData != null)
                  CycleProgressIndicator(
                    key: _indicatorKey,
                    predictionData: _predictionData!,
                  )
                else
                  const Text("Configura tu ciclo para ver el progreso"),
                const SizedBox(height: 35),
                HomeActionButtons(onRefresh: _loadAllData),
                const SizedBox(height: 25),
                PredictionCard(
                  predictionData: _predictionData,
                  onTap: (type) => _indicatorKey.currentState?.triggerGlow(markerType: type),
                  onCardTap: (type) {
                    if (_predictionData == null) return;
                    
                    DateTime? targetDate;
                    try {
                      if (type == 'fertile') {
                        final dateStr = _predictionData!['fertile_window']?['start'];
                        if (dateStr != null) targetDate = DateTime.parse(dateStr);
                      } else if (type == 'ovulation') {
                        final dateStr = _predictionData!['ovulation_date'];
                        if (dateStr != null) targetDate = DateTime.parse(dateStr);
                      } else if (type == 'period') {
                        final dateStr = _predictionData!['next_period_start'];
                        if (dateStr != null) targetDate = DateTime.parse(dateStr);
                      }
                    } catch (e) {
                      // Silently fail or handle invalid date
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarScreen(
                          predictionData: _predictionData,
                          initialDate: targetDate,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Holiii!! Bienvenida',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(initialUserData: _userProfileData),
                  ),
                ).then((_) => _loadAllData());
            },
          ),
        ),
      ],
    );
  }
}

