import 'package:flutter/material.dart';
import '../../data/admin_service.dart';
import '../widgets/shared/kpi_card.dart';
import '../widgets/shared/system_health_widget.dart';

class GlobalReportsScreen extends StatefulWidget {
  const GlobalReportsScreen({super.key});

  @override
  State<GlobalReportsScreen> createState() => _GlobalReportsScreenState();
}

class _GlobalReportsScreenState extends State<GlobalReportsScreen> {
  bool _isLoading = true;
  bool _isLoadingActivity = false;
  bool _isLoadingSecurity = false;
  bool _isLoadingHealth = false;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _userCounts;
  Map<String, dynamic>? _securityStats;
  Map<String, dynamic>? _systemHealth;

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
      AdminService.getSecurityStats(),
      AdminService.getSystemHealth(),
    ]);

    if (mounted) {
      setState(() {
        if (results[0]['success']) _stats = results[0]['data'];
        if (results[1]['success']) _userCounts = results[1]['data'];
        if (results[2]['success']) _securityStats = results[2]['data'];
        if (results[3]['success']) _systemHealth = results[3]['data'];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadActivity() async {
    setState(() => _isLoadingActivity = true);
    final result = await AdminService.getSecurityStats();
    if (mounted) {
      setState(() {
        if (result['success']) _securityStats = result['data'];
        _isLoadingActivity = false;
      });
    }
  }

  Future<void> _loadSecurity() async {
    setState(() => _isLoadingSecurity = true);
    final result = await AdminService.getStatistics();
    if (mounted) {
      setState(() {
        if (result['success']) _stats = result['data'];
        _isLoadingSecurity = false;
      });
    }
  }

  Future<void> _loadHealth() async {
    setState(() => _isLoadingHealth = true);
    final result = await AdminService.getSystemHealth();
    if (mounted) {
      setState(() {
        if (result['success']) _systemHealth = result['data'];
        _isLoadingHealth = false;
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _isLoading
            ? const LinearProgressIndicator(color: Colors.blue, backgroundColor: Colors.transparent, minHeight: 2)
            : Container(height: 2, color: Colors.transparent),
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
                      value: _isLoading ? '...' : '${_userCounts?['all'] ?? 0}',
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
                      value: _isLoading ? '...' : '${_stats?['failed_logins_24h'] ?? 0}',
                      subtitle: 'Últimas 24h',
                      icon: Icons.security_outlined,
                      color: Colors.redAccent,
                      delay: 200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Actividad Reciente', Icons.bolt_rounded, showRefresh: true, onRefresh: _loadActivity),
              const SizedBox(height: 16),
              _buildActivityTimeline(),

              const SizedBox(height: 32),
              _buildSectionHeader('Seguridad', Icons.shield_outlined, showRefresh: true, onRefresh: _loadSecurity),
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
                    if (_isLoading || _isLoadingSecurity)
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
              _buildSectionHeader('Infraestructura', Icons.developer_board_rounded, showRefresh: true, onRefresh: _loadHealth),
              const SizedBox(height: 16),
              
              SystemHealthWidget(
                uptime: (_systemHealth?['uptime'] ?? 99.9).toDouble(),
                status: _isLoadingHealth ? 'Actualizando' : (_systemHealth?['status'] ?? 'Cargando'),
                responseTime: _systemHealth?['response_time_ms'] ?? 0,
                modules: _systemHealth?['modules'] ?? [
                  {'name': 'Auth API', 'healthy': false},
                  {'name': 'Master DB', 'healthy': false},
                  {'name': 'Cloud Storage', 'healthy': false},
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {bool showRefresh = false, VoidCallback? onRefresh}) {
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
        if (showRefresh) ...[
          const Spacer(),
          GestureDetector(
            onTap: onRefresh ?? _loadAllData,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded, size: 16, color: Colors.black54),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActivityTimeline() {
    final auditLogs = (_securityStats?['audit_log'] as List?) ?? [];
    
    if (_isLoading || _isLoadingActivity) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text("Cargando actividad...", style: TextStyle(color: Colors.grey))),
      );
    }
    
    if (auditLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text("No hay actividad reciente", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: auditLogs.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 36.0),
          child: Divider(height: 24, color: Colors.grey[100]),
        ),
        itemBuilder: (context, index) {
          final act = auditLogs[index];
          IconData icon;
          Color iconColor;
          
          if (act['type'] == 'danger') {
            icon = Icons.gpp_bad_rounded;
            iconColor = Colors.redAccent;
          } else if (act['type'] == 'warning') {
            icon = Icons.warning_amber_rounded;
            iconColor = Colors.orange;
          } else if (act['type'] == 'success') {
            icon = Icons.check_circle_outline;
            iconColor = Colors.green;
          } else {
            icon = Icons.info_outline;
            iconColor = Colors.blue;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act['action'] ?? 'Acción',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${act['detail'] ?? ''} • ${act['time'] ?? 'Reciente'}',
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
