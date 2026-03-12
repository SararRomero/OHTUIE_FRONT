import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import 'user_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../home/calendar_screen.dart';
import '../../core/widgets/logout_modal.dart';
import '../../core/widgets/session_expired_modal.dart';
import 'cycle_history_screen.dart';
import '../emotions/emotions_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;
  const ProfileScreen({super.key, this.initialUserData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _name = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    if (widget.initialUserData != null) {
      _name = widget.initialUserData!['full_name'] ?? "Usuario";
      _email = widget.initialUserData!['email'] ?? "";
      _isLoading = false;
    }
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // Only show the blocking central spinner if we don't have any data yet
    if (_name.isEmpty) {
      setState(() => _isLoading = true);
    }
    
    final result = await UserService.getUserMe();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _name = result['data']['full_name'] ?? "Usuario";
          _email = result['data']['email'] ?? "";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        
        // If it's a credential error, show the expired modal
        final message = result['message'].toString().toLowerCase();
        if (message.contains("credentials") || message.contains("unauthorized") || message.contains("401")) {
             if (mounted) {
               showDialog(
                 context: context,
                 barrierDismissible: false,
                 barrierColor: Colors.black.withOpacity(0.3),
                 builder: (context) => const SessionExpiredModal(),
               );
             }
        } else if (_name.isEmpty) {
          // Only show generic error if we actually don't have data to show
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // Background blur handled by modal
      builder: (context) => const LogoutModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F5FF),
              Color(0xFFFCF0F5),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'OHTUIE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4081),
                            letterSpacing: 1.2,
                          ),
                        ),
                        _buildMenuButton(),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // User Info Card
                    _buildUserHeaderCard(),
                    
                    const SizedBox(height: 40),
                    
                    // General Section
                    const Text(
                      'General',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            Icons.access_time, 
                            "Historial de tus Ciclos",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CycleHistoryScreen()),
                              );
                            }
                          ),
                          Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 16, endIndent: 16),
                          _buildMenuItem(
                            Icons.calendar_today_outlined, 
                            "Tu Calendario",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CalendarScreen()),
                              );
                            }
                          ),
                          Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 16, endIndent: 16),
                          _buildMenuItem(
                            Icons.swap_calls_outlined, 
                            "Emociones",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EmotionsScreen()),
                              );
                            }
                          ),
                          Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 16, endIndent: 16),
                          _buildMenuItem(Icons.analytics_outlined, "Analisis de sus Ciclos"),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Support Section
                    const Text(
                      'Soporte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            Icons.lock_outline, 
                            "Cambiar Contraseña",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                              );
                            }
                          ),
                          Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 16, endIndent: 16),
                          _buildMenuItem(
                            Icons.logout, 
                            "Salir", 
                            isLogout: true,
                            onTap: _handleLogout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildUserHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFFFB2C1).withOpacity(0.2),
            child: const Icon(Icons.person, color: Color(0xFFFF4081), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen(name: _name, email: _email)),
              ).then((_) => _loadUserProfile());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {bool isLogout = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? const Color(0xFFFFF0F3) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, 
          color: isLogout ? Colors.redAccent : Colors.black87, 
          size: 22
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isLogout ? Colors.redAccent : Colors.black87,
        ),
      ),
      trailing: isLogout ? null : const Icon(Icons.chevron_right, color: Colors.black45, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

}
