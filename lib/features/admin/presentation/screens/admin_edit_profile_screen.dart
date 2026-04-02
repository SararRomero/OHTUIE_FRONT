import 'package:flutter/material.dart';
import '../../../profile/user_service.dart';
import '../../../../core/widgets/custom_notification.dart';
import '../../../../core/widgets/cycle_loading_button.dart';

class AdminEditProfileScreen extends StatefulWidget {
  const AdminEditProfileScreen({super.key});

  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    final result = await UserService.getUserMe();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _nameController.text = result['data']['full_name'] ?? "";
          _emailController.text = result['data']['email'] ?? "";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        CustomNotification.show(
          context, 
          message: 'Error al cargar datos: ${result['message']}', 
          type: NotificationType.error
        );
      }
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      CustomNotification.show(
        context, 
        message: 'Por favor, completa todos los campos', 
        type: NotificationType.warning
      );
      return;
    }

    setState(() => _isSaving = true);
    final result = await UserService.updateUserMe(fullName: name, email: email);
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (result['success']) {
        CustomNotification.show(
          context, 
          message: 'Datos actualizados correctamente', 
          type: NotificationType.success
        );
        Navigator.pop(context);
      } else {
        CustomNotification.show(
          context, 
          message: 'Error: ${result['message']}', 
          type: NotificationType.error
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF), // Soft background
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Tus datos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44), // To balance the back button
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Avatar Section
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      image: const DecorationImage(
                        image: AssetImage('lib/assets/image/logo_app.png'), // Placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                       fontSize: 22,
                       fontWeight: FontWeight.bold,
                       color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInputField(
                          label: 'Nombre completo',
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          icon: Icons.edit_outlined,
                        ),
                        const Divider(height: 32),
                        _buildInputField(
                          label: 'Email',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          icon: Icons.edit_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Save Button
                  CycleLoadingButton(
                    text: 'Guardar',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                    backgroundColor: const Color(0xFFFF4081),
                    borderRadius: 30,
                    height: 60,
                    showBorderAnimation: true,
                    useBorealisAnimation: false,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () => focusNode.requestFocus(),
              child: Icon(icon, color: Colors.black.withAlpha(100), size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
