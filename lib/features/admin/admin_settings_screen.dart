import 'dart:ui';
import 'package:flutter/material.dart';
import 'admin_edit_profile_screen.dart';
import '../../core/widgets/logout_modal.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF), // Soft bluish background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'OHTUIE',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4081),
                    ),
                  ),
                  Container(
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
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.menu, size: 24, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // User Profile Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminEditProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('lib/assets/image/logo_app.png'), // Placeholder
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Administradora',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'admin@ohtuie.com',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.edit_outlined, color: Colors.black.withAlpha(120)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // General Section
              const Text(
                'Administración',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                      icon: Icons.people_outline,
                      title: 'Gestión de Usuarias',
                      onTap: () {},
                      isFirst: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Estadísticas de Seguridad',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.bar_chart_outlined,
                      title: 'Reportes Globales',
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Support Section
              const Text(
                'Soporte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                      icon: Icons.analytics_outlined,
                      title: 'Análisis de Datos',
                      onTap: () {},
                      isFirst: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Log Out',
                      titleColor: const Color(0xFFFF5252),
                      iconColor: const Color(0xFFFF5252),
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent, // Background blur handled by modal
                          builder: (context) => const LogoutModal(),
                        );
                      },
                      isLast: true,
                      showChevron: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
    bool showChevron = true,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isFirst ? 24 : 0),
        topRight: Radius.circular(isFirst ? 24 : 0),
        bottomLeft: Radius.circular(isLast ? 24 : 0),
        bottomRight: Radius.circular(isLast ? 24 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.black).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor ?? Colors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
