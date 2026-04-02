import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'user_service.dart';
import '../../core/widgets/cycle_loading_button.dart';
import '../../core/widgets/custom_notification.dart';
import '../auth/login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isLoading = false;

  void _handleDelete() async {
    setState(() => _isLoading = true);
    final result = await UserService.deleteUserMe();
    
    if (mounted) {
      if (result['success']) {
        await AuthService.logout();
        if (context.mounted) {
          CustomNotification.show(
            context,
            message: 'Eliminación procesada con éxito. Revisa tu correo.',
            type: NotificationType.success,
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      } else {
        setState(() => _isLoading = false);
        CustomNotification.show(context, message: 'Error: ${result['message']}', type: NotificationType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Soft background color matching profile
      appBar: AppBar(
        title: const Text('Eliminar cuenta', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 32),
              const Text(
                'Sentimos que te vayas...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4081),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu cuenta se desactivará y se enviará a la papelera. Se eliminará de forma permanente dentro de 30 días. Si cambias de opinión, solo vuelve a iniciar sesión antes de que se cumpla el plazo para cancelar la eliminación.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              CycleLoadingButton(
                text: 'Sí, eliminar cuenta',
                isLoading: _isLoading,
                onPressed: _handleDelete,
                backgroundColor: Colors.red[400],
                borderRadius: 16,
                showBorderAnimation: true,
                useBorealisAnimation: false,
              ),
              const SizedBox(height: 16),
              if (!_isLoading) 
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
