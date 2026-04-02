import 'package:flutter/material.dart';
import 'user_service.dart';
import '../auth/auth_service.dart';
import 'delete_account_screen.dart';
import '../../core/widgets/cycle_loading_button.dart';
import '../../core/widgets/custom_notification.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;

  const EditProfileScreen({super.key, required this.name, required this.email});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late FocusNode _nameFocusNode;
  late FocusNode _emailFocusNode;
  bool _isLoading = false;
  
  // Avatar Editing State
  bool _isEditingAvatar = false;
  String? _selectedAvatarId;
  final List<String> _avatars = ['avatar_1', 'avatar_2', 'avatar_3', 'avatar_4', 'avatar_5'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _fetchProfile();
  }

  void _fetchProfile() async {
    final result = await UserService.getUserMe();
    if (result['success'] && mounted) {
      setState(() {
        _selectedAvatarId = result['data']['avatar_id'];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      CustomNotification.show(context, message: 'Por favor, completa todos los campos', type: NotificationType.warning);
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      CustomNotification.show(context, message: 'Por favor, ingresa un formato de email válido', type: NotificationType.warning);
      return;
    }

    setState(() => _isLoading = true);
    final result = await UserService.updateUserMe(
      fullName: name, 
      email: email,
      avatarId: _selectedAvatarId,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        CustomNotification.show(context, message: 'Información actualizada correctamente', type: NotificationType.success);
        Navigator.pop(context);
      } else {
        CustomNotification.show(context, message: 'Error: ${result['message']}', type: NotificationType.error);
      }
    }
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
            colors: [Color(0xFFFFF0F3), Color(0xFFE8EAF6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildAvatarSection(),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      children: [
                        _buildEditableField("Nombre completo", _nameController, _nameFocusNode, Icons.person_outline),
                        const SizedBox(height: 20),
                        _buildEditableField("Email", _emailController, _emailFocusNode, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 60),
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                        _buildDeleteAccountButton(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          const Text(
            'Tus datos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Main Circular Avatar
            Container(
              width: 130,
              height: 130,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isEditingAvatar ? const Color(0xFFFF4081) : const Color(0xFFFFB2C1), 
                  width: 3
                ),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFFCE4EC),
                backgroundImage: _selectedAvatarId != null 
                    ? AssetImage('lib/assets/image/avatars/$_selectedAvatarId.png')
                    : null,
                child: _selectedAvatarId == null 
                    ? const Icon(Icons.person, size: 60, color: Color(0xFFFF4081))
                    : null,
              ),
            ),
            
            // Edit/Check Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditingAvatar = !_isEditingAvatar;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4081),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Icon(
                    _isEditingAvatar ? Icons.check : Icons.edit,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Avatar Selection Slider (appears when editing)
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          height: _isEditingAvatar ? 80 : 0,
          margin: EdgeInsets.only(top: _isEditingAvatar ? 20 : 0),
          child: _isEditingAvatar ? ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _avatars.length,
            itemBuilder: (context, index) {
              final avatarId = _avatars[index];
              final isCurrent = _selectedAvatarId == avatarId;
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedAvatarId = avatarId);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? const Color(0xFFFF4081) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('lib/assets/image/avatars/$avatarId.png'),
                  ),
                ),
              );
            },
          ) : Container(),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, FocusNode focusNode, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => focusNode.requestFocus(),
                child: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return CycleLoadingButton(
      text: 'Guardar',
      isLoading: _isLoading,
      onPressed: _handleSave,
      backgroundColor: const Color(0xFFFF4081),
      borderRadius: 30,
      showBorderAnimation: true,
      useBorealisAnimation: false,
    );
  }

  Widget _buildDeleteAccountButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.red[300],
      ),
      child: const Text('Eliminar cuenta', style: TextStyle(fontSize: 16)),
    );
  }
}

