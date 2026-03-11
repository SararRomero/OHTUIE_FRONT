import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'admin_service.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  bool _isLoading = true;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final result = await AdminService.getUsers();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _users = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F3), // Light pink background
      appBar: AppBar(
        title: const Text('Gestión de Usuarios', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
          : _users.isEmpty
              ? const Center(child: Text('No hay usuarios registrados'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Text(
                          user['full_name'] ?? 'Sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email'] ?? ''),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (user['is_active'] ?? true) ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                (user['is_active'] ?? true) ? 'Activo' : 'Bloqueado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (user['is_active'] ?? true) ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF64B5F6)), // Light Blue
                              onPressed: () => _showEditUserDialog(user),
                            ),
                            IconButton(
                              icon: Icon(
                                (user['is_active'] ?? true) ? Icons.block : Icons.check_circle, 
                                color: (user['is_active'] ?? true) ? Colors.orange : Colors.green
                              ),
                              onPressed: () => _toggleUserStatus(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFE57373)), // Soft Red
                              onPressed: () => _deleteUser(user['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['full_name']);
    final emailController = TextEditingController(text: user['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final result = await AdminService.updateUser(user['id'], {
                'full_name': nameController.text,
                'email': emailController.text,
              });
              if (!mounted) return;
              Navigator.pop(context);
              if (result['success']) {
                _loadUsers();
                messenger.showSnackBar(const SnackBar(content: Text('Usuario actualizado')));
              } else {
                messenger.showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    final isActive = user['is_active'] ?? true;
    final action = isActive ? "Bloquear" : "Desbloquear";
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Estás seguro de que deseas $action a este usuario?'),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña de Administrador',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isActive ? Colors.orange : Colors.green),
            onPressed: () async {
               final messenger = ScaffoldMessenger.of(context);
               // 1. Verify Password
               final verify = await AdminService.verifyAdminPassword(passwordController.text);
               if (!verify['success']) {
                 if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(verify['message']), backgroundColor: Colors.red)
                    );
                 }
                 return;
               }

               // 2. Perform Action
              final result = await AdminService.updateUser(user['id'], {
                'is_active': !isActive,
              });
              
              if (!mounted) return;
              Navigator.pop(context);
              if (result['success']) {
                _loadUsers();
                messenger.showSnackBar(SnackBar(content: Text('Usuario ${isActive ? "bloqueado" : "desbloqueado"} correctamente')));
              } else {
                messenger.showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
              }
            },
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String userId) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.'),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña de Administrador',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
               final messenger = ScaffoldMessenger.of(context);
               // 1. Verify Password
               final verify = await AdminService.verifyAdminPassword(passwordController.text);
               if (!verify['success']) {
                 if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(verify['message']), backgroundColor: Colors.red)
                    );
                 }
                 return;
               }

              // 2. Perform Action
              final result = await AdminService.deleteUser(userId);
              if (!mounted) return;
              Navigator.pop(context);
              if (result['success']) {
                _loadUsers();
                messenger.showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
              } else {
                messenger.showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
