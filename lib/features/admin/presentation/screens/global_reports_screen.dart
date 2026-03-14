import 'package:flutter/material.dart';
import '../../data/admin_service.dart';
import '../widgets/shared/kpi_card.dart';
import '../widgets/shared/system_health_widget.dart';
import '../widgets/charts/age_distribution_chart.dart';
import '../widgets/charts/retention_chart.dart';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          KPICard(
                            title: 'Usuarias Totales',
                            value: '${_userCounts?['total'] ?? 0}',
                            subtitle: '+12% este mes',
                            icon: Icons.people_outline,
                            color: Colors.blue,
                            delay: 0,
                          ),
                          const SizedBox(width: 16),
                          KPICard(
                            title: 'Activas Hoy',
                            value: '${_userCounts?['active'] ?? 0}',
                            subtitle: '85% del total',
                            icon: Icons.bolt,
                            color: Colors.orange,
                            delay: 100,
                          ),
                          const SizedBox(width: 16),
                          KPICard(
                            title: 'Alertas Seg.',
                            value: '${_stats?['failed_logins']?.length ?? 0}',
                            subtitle: 'Últimas 24h',
                            icon: Icons.security_outlined,
                            color: Colors.redAccent,
                            delay: 200,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Charts Section
                    const Text(
                      'Análisis de Retención',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 240,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: RetentionChart(retentionData: _userCounts),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Distribución por Edad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: AgeDistributionChart(ageData: _stats?['age_distribution']),
                    ),
                    const SizedBox(height: 30),
                    // System Health
                    const SystemHealthWidget(
                      uptime: 99.9,
                      status: 'Operativo',
                      modules: [
                        {'name': 'Autenticación', 'healthy': true},
                        {'name': 'Base de Datos', 'healthy': true},
                        {'name': 'Servicio de Correos', 'healthy': true},
                        {'name': 'IA de Predicción', 'healthy': false},
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
