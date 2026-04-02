import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import '../../core/widgets/cycle_loading_button.dart';
import '../../core/widgets/custom_notification.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({super.key, required this.email, required this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void _handleResetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      CustomNotification.show(context, message: 'Por favor, completa ambos campos', type: NotificationType.warning);
      return;
    }

    if (password.length < 6) {
      CustomNotification.show(context, message: 'La contraseña debe tener al menos 6 caracteres', type: NotificationType.warning);
      return;
    }

    if (password != confirmPassword) {
      CustomNotification.show(context, message: 'Las contraseñas no coinciden', type: NotificationType.warning);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.resetPassword(
      email: widget.email,
      code: widget.code,
      newPassword: password,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        CustomNotification.show(context, message: 'Contraseña cambiada con éxito!', type: NotificationType.success);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        CustomNotification.show(context, message: 'Error: ${result['message']}', type: NotificationType.error);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            // Back Button
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
                        'Cambia tu contraseña',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Porfavor ingresa una nueva contraeña que no olvides!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text('Crea nueva contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          counterText: "",
                          helperText: 'Mínimo 6 y máximo 20 caracteres',
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('Confirma tu nueva contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        maxLength: 20,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          counterText: "",
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      CycleLoadingButton(
                        text: 'Guardar',
                        isLoading: _isLoading,
                        onPressed: _handleResetPassword,
                        backgroundColor: const Color(0xFFFFCCE5),
                        loadingColor: const Color(0xFFFF4081),
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
