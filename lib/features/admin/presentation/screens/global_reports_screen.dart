import 'package:flutter/material.dart';
import '../../data/admin_service.dart';
import '../widgets/shared/kpi_card.dart';
import '../widgets/shared/system_health_widget.dart';
import '../widgets/charts/age_distribution_chart.dart';

class GlobalReportsScreen extends StatefulWidget {
  const GlobalReportsScreen({super.key});

  @override
  State<GlobalReportsScreen> createState() => _GlobalReportsScreenState();
}

class _GlobalReportsScreenState extends State<GlobalReportsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _userCounts;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    // Load statistics and user counts in parallel
    final results = await Future.wait([
      AdminService.getStatistics(),
      AdminService.getUserCounts(),
    ]);

    if (mounted) {
      setState(() {
        if (results[0]['success']) _stats = results[0]['data'];
        if (results[1]['success']) _userCounts = results[1]['data'];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleExport() async {
    // Show a loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(width: 15),
            Text('Generando archivo Excel...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final result = await AdminService.exportUsersToExcel();

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Archivo generado exitosamente'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'CERRAR',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al exportar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text(
          'Reportes Globales',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen General',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // KPI Row
              SizedBox(
                height: 165,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    KPICard(
                      title: 'Usuarias Totales',
                      value: _isLoading ? '...' : '${_userCounts?['total'] ?? 0}',
                      subtitle: '+12% este mes',
                      icon: Icons.people_outline,
                      color: Colors.blue,
                      delay: 0,
                    ),
                    const SizedBox(width: 16),
                    KPICard(
                      title: 'Activas Hoy',
                      value: _isLoading ? '...' : '${_userCounts?['active'] ?? 0}',
                      subtitle: '85% del total',
                      icon: Icons.bolt,
                      color: Colors.orange,
                      delay: 100,
                    ),
                    const SizedBox(width: 16),
                    KPICard(
                      title: 'Alertas Seg.',
                      value: _isLoading ? '...' : '${_stats?['failed_logins']?.length ?? 0}',
                      subtitle: 'Últimas 24h',
                      icon: Icons.security_outlined,
                      color: Colors.redAccent,
                      delay: 200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Acciones Rápidas', Icons.grid_view_rounded),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Distribución Demográfica', Icons.pie_chart_outline),
              const SizedBox(height: 16),
              Container(
                height: 220,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : AgeDistributionChart(ageData: _stats?['age_distribution']),
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Actividad Reciente', Icons.bolt_rounded),
              const SizedBox(height: 16),
              _buildActivityTimeline(),

              const SizedBox(height: 32),
              _buildSectionHeader('Seguridad', Icons.shield_outlined),
              const SizedBox(height: 16),
              
              // Security Alerts Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Intentos de Acceso',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(),
                      ))
                    else if (_stats?['failed_logins'] == null || (_stats?['failed_logins'] as List).isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('Sin alertas recientes', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      )
                    else
                      ...(_stats?['failed_logins'] as List).take(2).map((login) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    login['email'] ?? 'Desconocido',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${login['ip_address'] ?? 'IP N/A'} • ${login['timestamp'] ?? 'Reciente'}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Infraestructura', Icons.developer_board_rounded),
              const SizedBox(height: 16),
              
              SystemHealthWidget(
                uptime: 99.9,
                status: 'Operativo',
                modules: [
                  {'name': 'Auth API', 'healthy': true},
                  {'name': 'Master DB', 'healthy': true},
                  {'name': 'Cloud Storage', 'healthy': true},
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {'title': 'Exportar', 'icon': Icons.download_rounded, 'color': Colors.indigo},
      {'title': 'Usuario+', 'icon': Icons.person_add_rounded, 'color': Colors.teal},
      {'title': 'Config', 'icon': Icons.settings_suggest_rounded, 'color': Colors.blueGrey},
      {'title': 'Soporte', 'icon': Icons.support_agent_rounded, 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (action['color'] as Color).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: index == 0 ? _handleExport : () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      action['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityTimeline() {
    final activities = [
      {'title': 'Parámetros de búsqueda actualizados', 'time': 'Hace 2h', 'user': 'Admin', 'icon': Icons.tune_rounded},
      {'title': 'Backup automático completado', 'time': 'Hace 5h', 'user': 'System', 'icon': Icons.cloud_done},
      {'title': 'Nueva actualización de seguridad', 'time': 'Ayer', 'user': 'Security', 'icon': Icons.verified_user},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 36.0),
          child: Divider(height: 24, color: Colors.grey[100]),
        ),
        itemBuilder: (context, index) {
          final act = activities[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(act['icon'] as IconData, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${act['user']} • ${act['time']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
