import 'package:flutter/material.dart';
import '../../data/admin_service.dart';
import '../widgets/shared/kpi_card.dart';
import 'package:fl_chart/fl_chart.dart';

class SecurityStatsScreen extends StatefulWidget {
  const SecurityStatsScreen({super.key});

  @override
  State<SecurityStatsScreen> createState() => _SecurityStatsScreenState();
}

class _SecurityStatsScreenState extends State<SecurityStatsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _securityData;

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  Future<void> _loadSecurityData() async {
    setState(() => _isLoading = true);
    
    final result = await AdminService.getSecurityStats();
    
    if (mounted) {
      setState(() {
        if (result['success']) {
          _securityData = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text(
          'Estadísticas de Seguridad',
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
        onRefresh: _loadSecurityData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Resumen de Amenazas', Icons.security_rounded, showRefresh: true),
              const SizedBox(height: 16),
              // Security KPIs
              SizedBox(
                height: 165,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    KPICard(
                      title: 'Intentos Fallidos',
                      value: _isLoading ? '...' : '${_securityData?['failed_logins_count'] ?? 0}',
                      subtitle: 'Últimas 24 horas',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      delay: 0,
                    ),
                    const SizedBox(width: 16),
                    KPICard(
                      title: 'Bloqueos Activos',
                      value: _isLoading ? '...' : '${_securityData?['active_lockouts'] ?? 0}',
                      subtitle: 'Cuentas restringidas',
                      icon: Icons.lock_person_rounded,
                      color: Colors.orange,
                      delay: 100,
                    ),
                    const SizedBox(width: 16),
                    KPICard(
                      title: 'Sesiones Admin',
                      value: _isLoading ? '...' : '${_securityData?['admin_sessions'] ?? 0}',
                      subtitle: 'Actualmente online',
                      icon: Icons.admin_panel_settings_rounded,
                      color: Colors.blue,
                      delay: 200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Distribución de Riesgos', Icons.pie_chart_rounded, showRefresh: true),
              const SizedBox(height: 16),
              _buildThreatChart(),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Registro de Auditoría', Icons.history_edu_rounded, showRefresh: true),
              const SizedBox(height: 16),
              _buildSecurityAuditLog(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {bool showRefresh = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.redAccent),
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
            onTap: _loadSecurityData,
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

  Widget _buildThreatChart() {
    final riskDist = _securityData?['risk_distribution'] as Map<String, dynamic>?;
    final passVal = (riskDist?['Pass'] ?? 0).toDouble();
    final userVal = (riskDist?['User'] ?? 0).toDouble();
    final tokenVal = (riskDist?['Token'] ?? 0).toDouble();
    final total = passVal + userVal + tokenVal;

    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.redAccent,
                          value: total > 0 ? passVal : 1,
                          title: 'Pass',
                          radius: 30,
                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: total > 0 ? userVal : 0,
                          title: 'User',
                          radius: 30,
                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.blue,
                          value: total > 0 ? tokenVal : 0,
                          title: 'Token',
                          radius: 30,
                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChartLegendItem('Contraseña errónea', Colors.redAccent),
                      const SizedBox(height: 8),
                      _buildChartLegendItem('Usuario inexistente', Colors.orange),
                      const SizedBox(height: 8),
                      _buildChartLegendItem('Token expirado', Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityAuditLog() {
    final logs = _securityData?['audit_log'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : logs.isEmpty
          ? const Center(child: Text('No hay registros de auditoría', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Divider(height: 24, color: Colors.grey[100]),
              ),
              itemBuilder: (context, index) {
                final log = logs[index];
                Color iconColor;
                IconData iconData;
                
                switch (log['type']) {
                  case 'warning':
                    iconColor = Colors.orange;
                    iconData = Icons.warning_rounded;
                    break;
                  case 'danger':
                    iconColor = Colors.redAccent;
                    iconData = Icons.gpp_bad_rounded;
                    break;
                  case 'info':
                    iconColor = Colors.blue;
                    iconData = Icons.info_outline_rounded;
                    break;
                  case 'success':
                    iconColor = Colors.green;
                    iconData = Icons.verified_user_rounded;
                    break;
                  default:
                    iconColor = Colors.grey;
                    iconData = Icons.article_rounded;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, size: 18, color: iconColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log['action'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            log['detail'] as String,
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            log['time'] as String,
                            style: TextStyle(fontSize: 10, color: Colors.grey[400], fontStyle: FontStyle.italic),
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
