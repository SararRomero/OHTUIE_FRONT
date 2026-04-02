import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import 'auth_service.dart';
import '../../core/widgets/cycle_loading_button.dart';
import '../../core/widgets/custom_notification.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleRecoverPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      CustomNotification.show(context, message: 'Por favor, ingresa tu email', type: NotificationType.warning);
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      CustomNotification.show(context, message: 'Por favor, ingresa un formato de email válido', type: NotificationType.warning);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.recoverPassword(email);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        CustomNotification.show(context, message: 'Código enviado! Revisa tu correo.', type: NotificationType.success);
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email))
        );
      } else if (result['statusCode'] == 429) {
        _showRateLimitDialog();
      } else {
        CustomNotification.show(context, message: 'Error: ${result['message']}', type: NotificationType.error);
      }
    }
  }

  void _showRateLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Agotado',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF90CAF9), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Has agotado el límite de solicitudes de recuperación por hoy. Por favor, intenta de nuevo mañana.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF90CAF9),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
              Color(0xFFFFF8F9),
              Color(0xFFFFE5E9),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // ... (Back Button remains same)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingresa tu correo',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Porfavor ingresa tu correo para poder cambiar tu contraseña.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'tu@email.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 40),

                      CycleLoadingButton(
                        text: 'Enviar Código',
                        isLoading: _isLoading,
                        onPressed: _handleRecoverPassword,
                        backgroundColor: const Color(0xFFFFCCE5),
                        borderRadius: 30,
                        showBorderAnimation: true,
                        useBorealisAnimation: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
