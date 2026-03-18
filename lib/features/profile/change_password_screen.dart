import 'dart:async';
import 'package:flutter/material.dart';
import 'user_service.dart';
import '../auth/forgot_password_screen.dart';

enum PasswordState { none, validating, correct, incorrect }

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  PasswordState _currentPasswordState = PasswordState.none;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_onCurrentPasswordChanged);
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_onCurrentPasswordChanged);
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onCurrentPasswordChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    final text = _currentPasswordController.text;
    if (text.isEmpty) {
      setState(() => _currentPasswordState = PasswordState.none);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      if (text.length < 4) return; 

      setState(() => _currentPasswordState = PasswordState.validating);
      final isValid = await UserService.verifyPassword(text);
      
      if (mounted) {
        setState(() {
          _currentPasswordState = isValid ? PasswordState.correct : PasswordState.incorrect;
        });
      }
    });
  }

  void _handleSave() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await UserService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada correctamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        // Here's the requested behavior for incorrect current password
        String message = result['message'] ?? "Error al cambiar la contraseña";
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('$message. ¿Deseas recuperar tu contraseña?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text('Recuperar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (_currentPasswordState) {
      case PasswordState.correct:
        borderColor = Colors.blue;
        break;
      case PasswordState.incorrect:
        borderColor = Colors.red;
        break;
      case PasswordState.validating:
        borderColor = Colors.orange;
        break;
      default:
        borderColor = Colors.grey.withOpacity(0.3);
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F3), Color(0xFFE8EAF6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contraseña Actual', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          decoration: InputDecoration(
                            hintText: 'Ingresa tu contraseña actual',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: borderColor, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: borderColor, width: 2.5),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Opacity(
                          opacity: _currentPasswordState == PasswordState.correct ? 1.0 : 0.5,
                          child: IgnorePointer(
                            ignoring: _currentPasswordState != PasswordState.correct,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nueva Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Nueva contraseña',
                                    prefixIcon: const Icon(Icons.lock_reset),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text('Confirmar Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    hintText: 'Repite la contraseña',
                                    prefixIcon: const Icon(Icons.lock_reset),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: (_isLoading || _currentPasswordState != PasswordState.correct) ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB2C1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Actualizar Contraseña', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
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
              child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
            ),
          ),
          const Expanded(
            child: Text(
              'Cambiar Contraseña',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }
}
