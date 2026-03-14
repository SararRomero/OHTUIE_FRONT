import 'package:flutter/material.dart';

class AdminUserPreviewList extends StatelessWidget {
  final List<dynamic> users;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final VoidCallback onViewAll;

  const AdminUserPreviewList({
    super.key,
    required this.users,
    required this.isLoading,
    this.error,
    required this.onRefresh,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayUsers = users.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gestión de Usuarios',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (isLoading)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: onRefresh),
            ],
          ),
          const SizedBox(height: 16),
          if (error != null && !isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(height: 4),
                    Text('No se pudieron cargar usuarios',
                        style: TextStyle(color: Colors.orange[700])),
                    const SizedBox(height: 4),
                    Text(error!,
                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            )
          else if (users.isEmpty && !isLoading)
            const Center(child: Text('No hay usuarios registrados'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayUsers.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final user = displayUsers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(user['full_name'] ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email'] ?? ''),
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink[50],
                    child: Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Color(0xFFFF4081)),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: onViewAll,
              child: const Text('Ver todos los usuarios',
                  style: TextStyle(color: Color(0xFFFF4081))),
            ),
          ),
        ],
      ),
    );
  }
}
