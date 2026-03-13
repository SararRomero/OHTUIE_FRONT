import 'dart:async';
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
  bool _isFetchingMore = false;
  List<dynamic> _users = [];
  int _currentPage = 1;
  final int _limit = 20;
  int _totalUsers = 0;
  String _currentStatus = "all";
  String _searchQuery = "";
  Timer? _debounce;
  final Set<String> _expandedUserIds = {};
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _statusTabs = [
    {"label": "Todas", "value": "all"},
    {"label": "Activas", "value": "active"},
    {"label": "Bloqueadas", "value": "blocked"},
    {"label": "Eliminadas", "value": "deleted"},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading && !_isFetchingMore && _users.length < _totalUsers) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _users.clear();
        _expandedUserIds.clear();
      });
    }

    final result = await AdminService.getUsers(
        page: _currentPage, limit: _limit, status: _currentStatus, search: _searchQuery);
    if (mounted) {
      if (result['success']) {
        setState(() {
          if (refresh) {
            _users = result['data']['items'] ?? [];
          } else {
            _users.addAll(result['data']['items'] ?? []);
          }
          _totalUsers = result['data']['total'] ?? 0;
          _isLoading = false;
          _isFetchingMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error fetching users'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadMoreUsers() async {
    setState(() {
      _isFetchingMore = true;
      _currentPage++;
    });
    await _loadUsers(refresh: false);
  }

  void _onTabChanged(String status) {
    if (_currentStatus == status) return;
    setState(() => _currentStatus = status);
    _loadUsers(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF), // Blue admin background
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No hay usuarios\nen esta categoría',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadUsers(refresh: true),
                        color: const Color(0xFFFF4081),
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          itemCount: _users.length + (_isFetchingMore ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            if (index == _users.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(color: Color(0xFFFF4081)),
                                ),
                              );
                            }
                            final user = _users[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar usuario',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _loadUsers(refresh: true);
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.search_rounded, color: Colors.grey, size: 24),
              onPressed: () {
                _loadUsers(refresh: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _statusTabs.length,
        itemBuilder: (context, index) {
          final tab = _statusTabs[index];
          final isSelected = _currentStatus == tab['value'];
          return GestureDetector(
            onTap: () => _onTabChanged(tab['value']!),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tab['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.grey[500],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: isSelected ? 16 : 15,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 3,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final bool isDeleted = user['deleted_at'] != null;
    final bool isActive = user['is_active'] ?? true;
    final String userId = user['id'].toString();
    final bool isExpanded = _expandedUserIds.contains(userId);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedUserIds.remove(userId);
                } else {
                  _expandedUserIds.add(userId);
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        (user['full_name'] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4081),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['full_name'] ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user['email'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? Colors.grey[200]
                                : (isActive ? Colors.green[50] : Colors.red[50]),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDeleted
                                  ? Colors.grey[400]!
                                  : (isActive ? Colors.green[200]! : Colors.red[200]!),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isDeleted
                                ? 'Eliminado'
                                : (isActive ? 'Activo' : 'Bloqueado'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDeleted
                                  ? Colors.grey[700]
                                  : (isActive ? Colors.green[700] : Colors.red[700]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron icon
                  if (!isDeleted)
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),
          
          // Expandable Actions Area
          if (isExpanded && !isDeleted)
            Container(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.edit_rounded,
                        label: 'Editar',
                        color: Colors.grey,
                        onTap: () => _showEditUserDialog(user),
                      ),
                      Container(width: 1, height: 24, color: const Color(0xFFEEEEEE)),
                      _buildActionButton(
                        icon: isActive ? Icons.lock_outline : Icons.lock_open_rounded,
                        label: isActive ? 'Bloquear' : 'Desbloquear',
                        color: Colors.grey,
                        onTap: () => _toggleUserStatus(user),
                      ),
                      Container(width: 1, height: 24, color: const Color(0xFFEEEEEE)),
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Eliminar',
                        color: Colors.grey,
                        onTap: () => _deleteUser(user['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['full_name']);
    final emailController = TextEditingController(text: user['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Editar Usuario', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4081),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final result = await AdminService.updateUser(user['id'], {
                'full_name': nameController.text,
                'email': emailController.text,
              });
              if (!mounted) return;
              Navigator.pop(context);
              if (result['success']) {
                _loadUsers(refresh: true);
                messenger.showSnackBar(const SnackBar(content: Text('Usuario actualizado'), backgroundColor: Colors.green));
              } else {
                messenger.showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('$action Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Estás segura de que deseas $action a este usuario?'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña de Administradora',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.orange : Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
               final messenger = ScaffoldMessenger.of(context);
               final verify = await AdminService.verifyAdminPassword(passwordController.text);
               if (!verify['success']) {
                 if (mounted) {
                    messenger.showSnackBar(SnackBar(content: Text(verify['message']), backgroundColor: Colors.red));
                 }
                 return;
               }

              final result = await AdminService.updateUser(user['id'], {'is_active': !isActive});
              if (!mounted) return;
              Navigator.pop(context);
              if (result['success']) {
                _loadUsers(refresh: true);
                messenger.showSnackBar(SnackBar(content: Text('Usuario ${isActive ? "bloqueado" : "desbloqueado"} correctamente'), backgroundColor: Colors.green));
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar Usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás segura de que deseas enviar este usuario a la papelera? (Se eliminará definitivamente en 30 días).'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña de Administradora',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
               final messenger = ScaffoldMessenger.of(context);
               final verify = await AdminService.verifyAdminPassword(passwordController.text);
               if (!verify['success']) {
                 if (mounted) {
                    messenger.showSnackBar(SnackBar(content: Text(verify['message']), backgroundColor: Colors.red));
                 }
                 return;
               }

              final result = await AdminService.deleteUser(userId);
              if (!mounted) return;
              Navigator.pop(context);
              if (result['success']) {
                _loadUsers(refresh: true);
                messenger.showSnackBar(const SnackBar(content: Text('Usuario enviado a la papelera'), backgroundColor: Colors.green));
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
